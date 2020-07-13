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

#endif
