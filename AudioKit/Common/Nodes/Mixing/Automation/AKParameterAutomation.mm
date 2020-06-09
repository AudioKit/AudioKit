// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKParameterAutomation.hpp"
#include <algorithm>

extern "C"
{
void* createAKParameterAutomation(AUScheduleParameterBlock scheduleParameterBlock) {
    return new AKParameterAutomation(scheduleParameterBlock);
}

void deleteAKParameterAutomation(void* automation) {
    delete static_cast<AKParameterAutomation*>(automation);
}

AURenderObserver getAKParameterAutomationObserverBlock(void* automation) {
    return static_cast<AKParameterAutomation*>(automation)->renderObserverBlock();
}

void playAKParameterAutomation(void* automation, const AVAudioTime* startTime, double rate) {
    static_cast<AKParameterAutomation*>(automation)->play(startTime, rate);
}

void stopAKParameterAutomation(void* automation) {
    static_cast<AKParameterAutomation*>(automation)->stop();
}

void setAKParameterAutomationRecordingEnabled(void* automation, AUParameterAddress address, bool enabled) {
    
}

bool getAKParameterAutomationRecordingEnabled(void* automation, AUParameterAddress address) {
    return false;
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
            while (data.iterator != data.points.cend()) {
                double rampStartTime = data.iterator->startTime / playbackRate;
                if (rampStartTime >= blockEndTime) break;
                AUEventSampleTime startTime = (rampStartTime - blockStartTime) * sampleRate;
                if (rampStartTime < blockStartTime) startTime = 0;
                scheduleAutomationPoint(startTime, parameter.first, *data.iterator++, 0);
            }
        }
    };
}

void AKParameterAutomation::play(const AVAudioTime* startTime, double rate)
{
    if (!startTime.isSampleTimeValid) {
        printf("WARNING: AKParameterAutomation::play(): invalid sample time, aborting play()\n");
        return;
    }

    std::lock_guard<std::mutex> lock(mutex);
    startSampleTime = startTime.sampleTime;
    sampleRate = startTime.sampleRate;
    playbackRate = rate;
    isPlaying = true;
    wasReset = true;
}

void AKParameterAutomation::stop()
{
    std::lock_guard<std::mutex> lock(mutex);
    isPlaying = false;
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
