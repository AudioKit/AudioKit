// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#include <AudioToolbox/AudioToolbox.h>
#include <AVFoundation/AVFoundation.h>

struct AKParameterAutomationPoint {
    AUValue targetValue;
    double startTime;
    double rampDuration;
    float rampTaper;
    float rampSkew;
};

#ifndef __cplusplus

void* createAKParameterAutomation(AUScheduleParameterBlock scheduleParameterBlock);

void deleteAKParameterAutomation(void* automation);

AURenderObserver getAKParameterAutomationObserverBlock(void* automation);

void playAKParameterAutomation(void* automation, const AVAudioTime* startTime, double rate);

void stopAKParameterAutomation(void* automation);

void setAKParameterAutomationRecordingEnabled(void* automation, AUParameterAddress address, bool enabled);

bool getAKParameterAutomationRecordingEnabled(void* automation, AUParameterAddress address);

/// If `points` is null, this returns the number of automation points for a given parameter.
/// If `points` is not null, this fills points with up to `capacity` points and returns the count filled.
size_t getAKParameterAutomationPoints(void* automation, AUParameterAddress address, struct AKParameterAutomationPoint* points, size_t capacity);

void addAKParameterAutomationPoints(void* automation, AUParameterAddress address, const struct AKParameterAutomationPoint* points, size_t count);

void setAKParameterAutomationPoints(void* automation, AUParameterAddress address, const struct AKParameterAutomationPoint* points, size_t count);

void clearAKParameterAutomationRange(void* automation, AUParameterAddress address, double startTime, double endTime);

void clearAKParameterAutomationPoints(void* automation, AUParameterAddress address);

#else

#include <map>
#include <vector>
#include <mutex>

class AKParameterAutomation
{
public:
    
    AKParameterAutomation(AUScheduleParameterBlock scheduleParameterBlock);
    
    AURenderObserver renderObserverBlock();

    /// Begin playback. startTime should correspond to time zero of the sequence. This will be the
    /// current time if starting playback at the beginning of the sequence. If starting at some point
    /// later, startTime should be the time in the past coresponding to time zero.
    void play(const AVAudioTime* startTime, double rate);

    /// Stop playback
    void stop();

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

    struct ParameterData {
        std::vector<AKParameterAutomationPoint> points;
        std::vector<AKParameterAutomationPoint>::const_iterator iterator;
    };

    std::map<AUParameterAddress, ParameterData> parameters;
    
    AUScheduleParameterBlock scheduleParameterBlock;

    std::mutex mutex;

    bool isPlaying, wasReset;

    double startSampleTime, sampleRate;

    double playbackRate;
};

#endif
