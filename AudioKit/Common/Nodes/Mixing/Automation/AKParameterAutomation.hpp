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

typedef struct AKParameterAutomationHelper* AKParameterAutomationHelperRef;

#ifndef __cplusplus

AKParameterAutomationHelperRef createAKParameterAutomation(AUScheduleParameterBlock scheduleParameterBlock);

void deleteAKParameterAutomation(AKParameterAutomationHelperRef automation);

AURenderObserver getAKParameterAutomationRenderObserverBlock(AKParameterAutomationHelperRef automation);

AUParameterAutomationObserver getAKParameterAutomationAutomationObserverBlock(AKParameterAutomationHelperRef automation);

void playAKParameterAutomation(AKParameterAutomationHelperRef automation, const AVAudioTime* startTime, double rate);

void stopAKParameterAutomation(AKParameterAutomationHelperRef automation);

void setAKParameterAutomationRecordingEnabled(AKParameterAutomationHelperRef automation, AUParameterAddress address, bool enabled);

bool getAKParameterAutomationRecordingEnabled(AKParameterAutomationHelperRef automation, AUParameterAddress address);

/// If `points` is null, this returns the number of automation points for a given parameter.
/// If `points` is not null, this fills points with up to `capacity` points and returns the count filled.
size_t getAKParameterAutomationPoints(AKParameterAutomationHelperRef automation, AUParameterAddress address, struct AKParameterAutomationPoint* points, size_t capacity);

void addAKParameterAutomationPoints(AKParameterAutomationHelperRef automation, AUParameterAddress address, const struct AKParameterAutomationPoint* points, size_t count);

void setAKParameterAutomationPoints(AKParameterAutomationHelperRef automation, AUParameterAddress address, const struct AKParameterAutomationPoint* points, size_t count);

void clearAKParameterAutomationRange(AKParameterAutomationHelperRef automation, AUParameterAddress address, double startTime, double endTime);

void clearAKParameterAutomationPoints(AKParameterAutomationHelperRef automation, AUParameterAddress address);

#endif
