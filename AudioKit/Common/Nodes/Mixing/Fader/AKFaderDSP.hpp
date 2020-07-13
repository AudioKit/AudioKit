// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "AKParameterRamp.hpp"

typedef NS_ENUM (AUParameterAddress, AKFaderParameter) {
    AKFaderParameterLeftGain,
    AKFaderParameterRightGain,
    AKFaderParameterFlipStereo,
    AKFaderParameterMixToMono
};

#ifndef __cplusplus

AKDSPRef createFaderDSP(void);

#endif
