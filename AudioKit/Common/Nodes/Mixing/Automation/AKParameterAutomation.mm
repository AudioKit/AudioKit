// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKParameterAutomation.hpp"
#include <algorithm>
#include <mach/mach_time.h>

extern "C"
{
void* createAKParameterAutomation(AUScheduleParameterBlock scheduleParameterBlock) {
    return new AKParameterAutomation(scheduleParameterBlock);
}

void deleteAKParameterAutomation(void* automation) {
    delete static_cast<AKParameterAutomation*>(automation);
}

AURenderObserver getAKParameterAutomationRenderObserverBlock(void* automation) {
    return static_cast<AKParameterAutomation*>(automation)->renderObserverBlock();
}

AUParameterAutomationObserver getAKParameterAutomationAutomationObserverBlock(void* automation) {
    return static_cast<AKParameterAutomation*>(automation)->automationObserverBlock();
}

void playAKParameterAutomation(void* automation, const AVAudioTime* startTime, double rate) {
    static_cast<AKParameterAutomation*>(automation)->play(startTime, rate);
}

void stopAKParameterAutomation(void* automation) {
    static_cast<AKParameterAutomation*>(automation)->stop();
}

void setAKParameterAutomationRecordingEnabled(void* automation, AUParameterAddress address, bool enabled) {
    if (enabled) static_cast<AKParameterAutomation*>(automation)->enableRecording(address);
    else         static_cast<AKParameterAutomation*>(automation)->disableRecording(address);
}

bool getAKParameterAutomationRecordingEnabled(void* automation, AUParameterAddress address) {
    return static_cast<AKParameterAutomation*>(automation)->isRecordingEnabled(address);
}

size_t getAKParameterAutomationPoints(void* automation, AUParameterAddress address, AKParameterAutomationPoint* points, size_t capacity) {
    return static_cast<AKParameterAutomation*>(automation)->getPoints(address, points, capacity);
}

void addAKParameterAutomationPoints(void* automation, AUParameterAddress address, const AKParameterAutomationPoint* points, size_t count) {
    return static_cast<AKParameterAutomation*>(automation)->addPoints(address, points, count);
}

void setAKParameterAutomationPoints(void* automation, AUParameterAddress address, const AKParameterAutomationPoint* points, size_t count) {
    return static_cast<AKParameterAutomation*>(automation)->setPoints(address, points, count);
}

void clearAKParameterAutomationRange(void* automation, AUParameterAddress address, double startTime, double endTime) {
    static_cast<AKParameterAutomation*>(automation)->clearRange(address, startTime, endTime);
}

void clearAKParameterAutomationPoints(void* automation, AUParameterAddress address) {
    static_cast<AKParameterAutomation*>(automation)->clearAllPoints(address);
}
}

AKParameterAutomation::AKParameterAutomation(AUScheduleParameterBlock scheduleParameterBlock)
: scheduleParameterBlock(scheduleParameterBlock)
, isPlaying(false)
, wasReset(false)
{
}

void AKParameterAutomation::scheduleAutomationPoint(AUEventSampleTime blockTime,
                                                    AUParameterAddress address,
                                                    const AKParameterAutomationPoint& point,
                                                    AUAudioFrameCount rampOffset)
{
    AUParameterAddress mask;

    // set taper (as "value" parameter)
    mask = (AUParameterAddress)1 << 63;
    scheduleParameterBlock(AUEventSampleTimeImmediate + blockTime, 0, address | mask, point.rampTaper);

    // set skew (as "value" parameter)
    mask = (AUParameterAddress)1 << 62;
    scheduleParameterBlock(AUEventSampleTimeImmediate + blockTime, 0, address | mask, point.rampSkew);

    // set offset (as "duration" parameter)
    mask = (AUParameterAddress)1 << 61;
    scheduleParameterBlock(AUEventSampleTimeImmediate + blockTime, rampOffset, address | mask, 0);

    // set value
    AUAudioFrameCount rampDuration = point.rampDuration / playbackRate * sampleRate;
    scheduleParameterBlock(AUEventSampleTimeImmediate + blockTime, rampDuration, address, point.targetValue);
}

AURenderObserver AKParameterAutomation::renderObserverBlock()
{
    return ^void(AudioUnitRenderActionFlags actionFlags,
                 const AudioTimeStamp *timestamp,
                 AUAudioFrameCount frameCount,
                 NSInteger outputBusNumber)
    {
        if (actionFlags != kAudioUnitRenderAction_PreRender) return;

        std::unique_lock<std::mutex> lock(mutex, std::try_to_lock);
        if (!lock.owns_lock()) return;

        if (!isPlaying) return;

        double blockStartTime = (timestamp->mSampleTime - startSampleTime) / sampleRate;
        double blockEndTime = blockStartTime + frameCount / sampleRate;

        if (wasReset) {
            // reset iterators and fast forward to now, handling past events
            wasReset = false;
            for (auto& parameter : parameters) {
                ParameterData& data = parameter.second;
                data.iterator = data.points.cbegin();
                while (data.iterator != data.points.cend()) {
                    double rampStartTime = data.iterator->startTime / playbackRate;
                    double rampEndTime = rampStartTime + data.iterator->rampDuration / playbackRate;

                    if (rampStartTime < blockStartTime) {
                        if (rampEndTime <= blockStartTime) {
                            // ramp is completely finished at this point, set to target value
                            scheduleParameterBlock(AUEventSampleTimeImmediate, 0, parameter.first, data.iterator->targetValue);
                        }
                        else {
                            // we're starting mid-ramp: start immediately with offset
                            AUAudioFrameCount offset = (blockStartTime - rampStartTime) * sampleRate;
                            scheduleAutomationPoint(0, parameter.first, *data.iterator, offset);
                        }
                        data.iterator++;
                    }
                    else {
                        break;
                    }
                }
            }
        }

        for (auto& parameter : parameters) {
            ParameterData& data = parameter.second;
            std::unique_lock<std::mutex> recordingLock(recordingMutex, std::try_to_lock);
            if (!recordingLock.owns_lock() || isActivelyRecording(parameter.first)) continue;
            while (data.iterator != data.points.cend()) {
                double rampStartTime = data.iterator->startTime / playbackRate;
                if (rampStartTime >= blockEndTime) break;
                AUEventSampleTime startTime = (rampStartTime - blockStartTime) * sampleRate;
                if (rampStartTime < blockStartTime) startTime = 0; // should never happen?
                scheduleAutomationPoint(startTime, parameter.first, *data.iterator++, 0);
            }
        }

        lastRenderTime = blockEndTime;
    };
}

bool AKParameterAutomation::isActivelyRecording(AUParameterAddress address)
{
    auto& parameter = parameters[address];
    return !parameter.recordedSegments.empty() && parameter.recordedSegments.back().inProgress;
}

double AKParameterAutomation::getSequenceTime(uint64_t hostTime)
{
    struct mach_timebase_info timebase;
    mach_timebase_info(&timebase);
    double freq = static_cast<double>(timebase.denom) / static_cast<double>(timebase.numer) * 1000000000.0;
    double ticks = hostTime - startHostTime;
    return ticks / freq;
}

AUParameterAutomationObserver AKParameterAutomation::automationObserverBlock()
{
    return ^void(NSInteger numberEvents, const AUParameterAutomationEvent *events) {
        if (!isPlaying) return;
        std::lock_guard<std::mutex> lock(recordingMutex);
        for (NSInteger i = 0; i < numberEvents; i++) {
            const auto& event = events[i];
            auto& parameter = parameters[event.address];
            if (!parameter.recordingEnabled) continue;
            double sequenceTime = getSequenceTime(event.hostTime) * playbackRate;
            if (event.eventType == AUParameterAutomationEventTypeTouch) {
                // ignores touch events received during an active segment
                if (parameter.recordedSegments.empty() || !parameter.recordedSegments.back().inProgress) {
                    // push back new segment
                    parameter.recordedSegments.emplace_back();
                    auto& segment = parameter.recordedSegments.back();
                    segment.startTime = sequenceTime;
                    segment.recordedPoints.emplace_back(event.value, sequenceTime);
                }
            }
            else if (event.eventType == AUParameterAutomationEventTypeValue) {
                // ignores value events received outside of an active segment
                if (!parameter.recordedSegments.empty()) {
                    // add new point to segment
                    auto& segment = parameter.recordedSegments.back();
                    if (segment.inProgress) {
                        segment.recordedPoints.emplace_back(event.value, sequenceTime);
                    }
                }
            }
            else { //event.eventType == release
                // ignores release events received outside of an active segment
                if (!parameter.recordedSegments.empty()) {
                    // add new point to segment and complete segment
                    auto& segment = parameter.recordedSegments.back();
                    if (segment.inProgress) {
                        segment.recordedPoints.emplace_back(event.value, sequenceTime);
                        segment.endTime = sequenceTime;
                        segment.inProgress = false;
                    }
                }
            }
        }
    };
}

void AKParameterAutomation::play(const AVAudioTime* startTime, double rate)
{
    stop();

    if (!startTime.isSampleTimeValid) {
        printf("WARNING: AKParameterAutomation::play(): invalid sample time, aborting play()\n");
        return;
    }

    std::lock_guard<std::mutex> lock(mutex);
    startHostTime = startTime.hostTime;
    startSampleTime = startTime.sampleTime;
    sampleRate = startTime.sampleRate;
    playbackRate = rate;
    isPlaying = true;
    wasReset = true;
}

void AKParameterAutomation::stop()
{
    std::lock_guard<std::mutex> lock(mutex);
    if (!isPlaying) return; isPlaying = false;

    // set stop time for any actively recording segments
    std::lock_guard<std::mutex> recordLock(recordingMutex);
    for (auto& parameter : parameters) {
        auto& data = parameter.second;
        if (!data.recordedSegments.empty()) {
            auto& segment = data.recordedSegments.back();
            if (segment.inProgress) {
                // set end time to time of last point and complete segment
                segment.endTime = segment.recordedPoints.back().second;
                segment.inProgress = false;
            }
        }
    }

    reconcileRecordedSegments();
}

void AKParameterAutomation::enableRecording(AUParameterAddress address)
{
    std::lock_guard<std::mutex> lock(recordingMutex);
    parameters[address].recordingEnabled = true;
}

void AKParameterAutomation::disableRecording(AUParameterAddress address)
{
    std::lock_guard<std::mutex> lock(recordingMutex);
    auto& parameter = parameters[address];
    if (!parameter.recordingEnabled) return; parameter.recordingEnabled = false;

    // complete in-progress segment (if present)
    std::lock_guard<std::mutex> recordLock(recordingMutex);
    if (!parameter.recordedSegments.empty()) {
        auto& segment = parameter.recordedSegments.back();
        if (segment.inProgress) {
            // set end time to time of last point and complete segment
            segment.endTime = segment.recordedPoints.back().second;
            segment.inProgress = false;
        }
    }
}

bool AKParameterAutomation::isRecordingEnabled(AUParameterAddress address) const
{
    auto parametersIter = parameters.find(address);
    return parametersIter != parameters.cend() ? parametersIter->second.recordingEnabled : false;
}

void AKParameterAutomation::reconcileRecordedSegments()
{
    for (auto& parameter : parameters) {
        ParameterData& data = parameter.second;
        for (auto& segment : data.recordedSegments) {
            // clear existing points in segment range
            auto rend = std::remove_if(data.points.begin(), data.points.end(), [segment](auto a) {
                return segment.startTime <= a.startTime && a.startTime <= segment.endTime;
            });
            data.points.erase(rend, data.points.end());

            // append recorded points
            for (auto& point : segment.recordedPoints) {
                data.points.emplace_back(AKParameterAutomationPoint{
                    .targetValue = point.first,
                    .startTime = point.second,
                    .rampDuration = 0.01,
                    .rampTaper = 1,
                    .rampSkew = 0
                });
            }
        }

        // clear recorded segments and sort points vector
        data.recordedSegments.clear();
        std::sort(data.points.begin(), data.points.end(), [](auto a, auto b) {
            return a.startTime < b.startTime;
        });
    }

    wasReset = true;
}

size_t AKParameterAutomation::getPoints(AUParameterAddress address, AKParameterAutomationPoint* points, size_t capacity) const
{
    auto parametersIter = parameters.find(address);
    if (parametersIter == parameters.cend()) return 0;

    const auto& parameter = parametersIter->second;
    if (points) {
        size_t size = std::min(parameter.points.size(), capacity);
        std::copy_n(parameter.points.data(), size, points);
        return size;
    }
    else {
        return parameter.points.size();
    }
}

void AKParameterAutomation::addPoints(AUParameterAddress address, const AKParameterAutomationPoint* points, size_t count)
{
    std::lock_guard<std::mutex> lock(mutex);
    auto& parameter = parameters[address];
    parameter.points.insert(parameter.points.end(), points, points + count);
    std::sort(parameter.points.begin(), parameter.points.end(), [](auto a, auto b) {
        return a.startTime < b.startTime;
    });
    wasReset = true;
}

void AKParameterAutomation::setPoints(AUParameterAddress address, const AKParameterAutomationPoint* points, size_t count)
{
    std::lock_guard<std::mutex> lock(mutex);
    auto& parameter = parameters[address];
    parameter.points.assign(points, points + count);
    std::sort(parameter.points.begin(), parameter.points.end(), [](auto a, auto b) {
        return a.startTime < b.startTime;
    });
    wasReset = true;
}

void AKParameterAutomation::clearRange(AUParameterAddress address, double startTime, double endTime)
{
    std::lock_guard<std::mutex> lock(mutex);
    auto& parameter = parameters[address];
    auto rend = std::remove_if(parameter.points.begin(), parameter.points.end(), [startTime, endTime](auto a) {
        return startTime <= a.startTime && a.startTime <= endTime;
    });
    parameter.points.erase(rend, parameter.points.end());
    wasReset = true;
}

void AKParameterAutomation::clearAllPoints(AUParameterAddress address)
{
    std::lock_guard<std::mutex> lock(mutex);
    auto& parameter = parameters[address];
    parameter.points.clear();
    wasReset = true;
}
