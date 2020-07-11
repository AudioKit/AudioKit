// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKPhaseLockedVocoderParameter) {
    AKPhaseLockedVocoderParameterPosition,
    AKPhaseLockedVocoderParameterAmplitude,
    AKPhaseLockedVocoderParameterPitchRatio,
};

#ifndef __cplusplus

AKDSPRef createPhaseLockedVocoderDSP(void);

#endif
