// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKStereoDelayParameter) {
    AKStereoDelayParameterTime,
    AKStereoDelayParameterFeedback,
    AKStereoDelayParameterDryWetMix,
    AKStereoDelayParameterPingPong,
};

#ifndef __cplusplus

AKDSPRef createStereoDelayDSP(void);

#endif
