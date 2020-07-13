// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKParameterAutomation.hpp"
#include <algorithm>
#include <mach/mach_time.h>
#include <map>
#include <vector>
#include <list>
#include <utility>
#include <mutex>

class AKParameterAutomationHelper
{
public:

    AKParameterAutomationHelper(AUScheduleParameterBlock scheduleParameterBlock);

    AURenderObserver renderObserverBlock();

    AUParameterAutomationObserver automationObserverBlock();

    /// Begin playback. startTime should correspond to time zero of the sequence. This will be the
    /// current time if starting playback at the beginning of the sequence. If starting at some point
    /// later, startTime should be the time in the past coresponding to time zero.
    void play(const AVAudioTime* startTime, double rate);

    /// Stop playback
    void stop();

    void enableRecording(AUParameterAddress address);

    void disableRecording(AUParameterAddress address);

    bool isRecordingEnabled(AUParameterAddress address) const;

    /// If `points` is null, this returns the number of automation points for a given parameter.
    /// If `points` is not null, this fills points with up to `capacity` points and returns the count filled.
    /// This is all so that we can allocate a buffer Swift-side that is filled by this function.
    size_t getPoints(AUParameterAddress address, AKParameterAutomationPoint* points, size_t capacity) const;

    /// Add automation points to the given parameter without modifying existing points
    void addPoints(AUParameterAddress address, const AKParameterAutomationPoint* points, size_t count);

    /// Set the automation points of a given parameter, clearing any existing points
    void setPoints(AUParameterAddress address, const AKParameterAutomationPoint* points, size_t count);

    /// Clear a time range of automation points
    void clearRange(AUParameterAddress address, double startTime, double endTime);

    /// Clear all automation points of a given parameter
    void clearAllPoints(AUParameterAddress address);

private:

    /// Helper function which schedules taper, skew, and offset, in addition to the actual ramp event
    void scheduleAutomationPoint(AUEventSampleTime blockTimeOffset,
                                 AUParameterAddress address,
                                 const AKParameterAutomationPoint& point,
                                 AUAudioFrameCount rampOffset);

    /// Different from recording enabled, this returns true if we are in the middle of an active recording,
    /// i.e. we have receiveda touch event for this parameter and have not yet received a release event
    bool isActivelyRecording(AUParameterAddress address);

    /// Return the time (seconds) from the start time given the absolute host time.
    /// Only guaranteed valid during active playback,
    double getSequenceTime(uint64_t hostTime);

    /// Called from stop(), this updates the main points data vectors with any pending recorded data.
    /// The mutex lock is assumed to be held prior to this call to prevent render scheduling races.
    void reconcileRecordedSegments();

    struct ParameterData {
        std::vector<AKParameterAutomationPoint> points;
        std::vector<AKParameterAutomationPoint>::const_iterator iterator;

        /// Data for any changes occurring during parameter recording
        struct RecordedSegment {
            /// Stores all points recorded during this segment. Pair is <parameter value, sequence time>
            std::list<std::pair<AUValue, double>> recordedPoints;
            double startTime, endTime;
            bool inProgress = true;
        };

        /// Stores segments which have been recorded but not yet added to the main points vector.
        /// Any time stop() is called, this vector is added to the points vector and cleared.
        std::vector<RecordedSegment> recordedSegments;

        bool recordingEnabled = false;
    };

    std::map<AUParameterAddress, ParameterData> parameters;

    AUScheduleParameterBlock scheduleParameterBlock;

    /// Used to synchronize render notify observer
    std::mutex mutex;

    /// Used to synchronize automation observer
    std::mutex recordingMutex;

    bool isPlaying, wasReset;

    /// Absolute start time during playback
    uint64_t startHostTime;
    double startSampleTime;

    double playbackRate, sampleRate;

    /// The last time that the render observer was called, in seconds, relative to sequence start
    double lastRenderTime;
};


extern "C"
{
AKParameterAutomationHelperRef createAKParameterAutomation(AUScheduleParameterBlock scheduleParameterBlock) {
    return new AKParameterAutomationHelper(scheduleParameterBlock);
}

void deleteAKParameterAutomation(AKParameterAutomationHelperRef automation) {
    delete automation;
}

AURenderObserver getAKParameterAutomationRenderObserverBlock(AKParameterAutomationHelperRef automation) {
    return automation->renderObserverBlock();
}

AUParameterAutomationObserver getAKParameterAutomationAutomationObserverBlock(AKParameterAutomationHelperRef automation) {
    return automation->automationObserverBlock();
}

void playAKParameterAutomation(AKParameterAutomationHelperRef automation, const AVAudioTime* startTime, double rate) {
    automation->play(startTime, rate);
}

void stopAKParameterAutomation(AKParameterAutomationHelperRef automation) {
    automation->stop();
}

void setAKParameterAutomationRecordingEnabled(AKParameterAutomationHelperRef automation, AUParameterAddress address, bool enabled) {
    if (enabled) automation->enableRecording(address);
    else         automation->disableRecording(address);
}

bool getAKParameterAutomationRecordingEnabled(AKParameterAutomationHelperRef automation, AUParameterAddress address) {
    return automation->isRecordingEnabled(address);
}

size_t getAKParameterAutomationPoints(AKParameterAutomationHelperRef automation, AUParameterAddress address, AKParameterAutomationPoint* points, size_t capacity) {
    return automation->getPoints(address, points, capacity);
}

void addAKParameterAutomationPoints(AKParameterAutomationHelperRef automation, AUParameterAddress address, const AKParameterAutomationPoint* points, size_t count) {
    return automation->addPoints(address, points, count);
}

void setAKParameterAutomationPoints(AKParameterAutomationHelperRef automation, AUParameterAddress address, const AKParameterAutomationPoint* points, size_t count) {
    return automation->setPoints(address, points, count);
}

void clearAKParameterAutomationRange(AKParameterAutomationHelperRef automation, AUParameterAddress address, double startTime, double endTime) {
    automation->clearRange(address, startTime, endTime);
}

void clearAKParameterAutomationPoints(AKParameterAutomationHelperRef automation, AUParameterAddress address) {
    automation->clearAllPoints(address);
}
}

AKParameterAutomationHelper::AKParameterAutomationHelper(AUScheduleParameterBlock scheduleParameterBlock)
: scheduleParameterBlock(scheduleParameterBlock)
, isPlaying(false)
, wasReset(false)
{
}

void AKParameterAutomationHelper::scheduleAutomationPoint(AUEventSampleTime blockTime,
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

AURenderObserver AKParameterAutomationHelper::renderObserverBlock()
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

bool AKParameterAutomationHelper::isActivelyRecording(AUParameterAddress address)
{
    auto& parameter = parameters[address];
    return !parameter.recordedSegments.empty() && parameter.recordedSegments.back().inProgress;
}

double AKParameterAutomationHelper::getSequenceTime(uint64_t hostTime)
{
    struct mach_timebase_info timebase;
    mach_timebase_info(&timebase);
    double freq = static_cast<double>(timebase.denom) / static_cast<double>(timebase.numer) * 1000000000.0;
    double ticks = hostTime - startHostTime;
    return ticks / freq;
}

AUParameterAutomationObserver AKParameterAutomationHelper::automationObserverBlock()
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

void AKParameterAutomationHelper::play(const AVAudioTime* startTime, double rate)
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

void AKParameterAutomationHelper::stop()
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

void AKParameterAutomationHelper::enableRecording(AUParameterAddress address)
{
    std::lock_guard<std::mutex> lock(recordingMutex);
    parameters[address].recordingEnabled = true;
}

void AKParameterAutomationHelper::disableRecording(AUParameterAddress address)
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

bool AKParameterAutomationHelper::isRecordingEnabled(AUParameterAddress address) const
{
    auto parametersIter = parameters.find(address);
    return parametersIter != parameters.cend() ? parametersIter->second.recordingEnabled : false;
}

void AKParameterAutomationHelper::reconcileRecordedSegments()
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

size_t AKParameterAutomationHelper::getPoints(AUParameterAddress address, AKParameterAutomationPoint* points, size_t capacity) const
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

void AKParameterAutomationHelper::addPoints(AUParameterAddress address, const AKParameterAutomationPoint* points, size_t count)
{
    std::lock_guard<std::mutex> lock(mutex);
    auto& parameter = parameters[address];
    parameter.points.insert(parameter.points.end(), points, points + count);
    std::sort(parameter.points.begin(), parameter.points.end(), [](auto a, auto b) {
        return a.startTime < b.startTime;
    });
    wasReset = true;
}

void AKParameterAutomationHelper::setPoints(AUParameterAddress address, const AKParameterAutomationPoint* points, size_t count)
{
    std::lock_guard<std::mutex> lock(mutex);
    auto& parameter = parameters[address];
    parameter.points.assign(points, points + count);
    std::sort(parameter.points.begin(), parameter.points.end(), [](auto a, auto b) {
        return a.startTime < b.startTime;
    });
    wasReset = true;
}

void AKParameterAutomationHelper::clearRange(AUParameterAddress address, double startTime, double endTime)
{
    std::lock_guard<std::mutex> lock(mutex);
    auto& parameter = parameters[address];
    auto rend = std::remove_if(parameter.points.begin(), parameter.points.end(), [startTime, endTime](auto a) {
        return startTime <= a.startTime && a.startTime <= endTime;
    });
    parameter.points.erase(rend, parameter.points.end());
    wasReset = true;
}

void AKParameterAutomationHelper::clearAllPoints(AUParameterAddress address)
{
    std::lock_guard<std::mutex> lock(mutex);
    auto& parameter = parameters[address];
    parameter.points.clear();
    wasReset = true;
}
