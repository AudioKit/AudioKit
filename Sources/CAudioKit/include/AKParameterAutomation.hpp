// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#include <AudioToolbox/AudioToolbox.h>
#include <AVFoundation/AVFoundation.h>

struct AKParameterAutomationPoint {
    AUValue targetValue;
    float startTime;
    float rampDuration;
    float rampTaper;
    float rampSkew;
};

/// Linear automation segment.
struct AKAutomationEvent {
    AUValue targetValue;
    float startTime;
    float rampDuration;
};

#ifndef __cplusplus

/// Returns a render observer block which will apply the automation to the selected parameter.
AURenderObserver AKParameterAutomationGetRenderObserver(AUParameterAddress address,
                                                        AUScheduleParameterBlock scheduleParameterBlock,
                                                        float sampleRate,
                                                        float startSampleTime,
                                                        const struct AKAutomationEvent* events,
                                                        size_t count);

#endif
