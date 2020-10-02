// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#include <AudioToolbox/AudioToolbox.h>
#include <AVFoundation/AVFoundation.h>

/// One point in a parameter automation curve
struct ParameterAutomationPoint {
    AUValue targetValue;
    float startTime;
    float rampDuration;
    float rampTaper;
    float rampSkew;
};

/// Linear automation segment.
struct AutomationEvent {
    AUValue targetValue;
    float startTime;
    float rampDuration;
};

#ifndef __cplusplus

/// Returns a render observer block which will apply the automation to the selected parameter.
AURenderObserver ParameterAutomationGetRenderObserver(AUParameterAddress address,
                                                      AUScheduleParameterBlock scheduleParameterBlock,
                                                      float sampleRate,
                                                      float startSampleTime,
                                                      const struct AutomationEvent* events,
                                                      size_t count);

#endif
