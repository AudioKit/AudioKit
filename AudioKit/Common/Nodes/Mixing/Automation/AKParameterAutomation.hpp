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

AURenderObserver getAKParameterAutomationRenderObserverBlock(void* automation);

AUParameterAutomationObserver getAKParameterAutomationAutomationObserverBlock(void* automation);

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
#include <list>
#include <utility>
#include <mutex>

class AKParameterAutomation
{
public:
    
    AKParameterAutomation(AUScheduleParameterBlock scheduleParameterBlock);
    
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

#endif
