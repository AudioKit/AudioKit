// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKDynaRageCompressorParameter) {
    AKDynaRageCompressorParameterRatio,
    AKDynaRageCompressorParameterThreshold,
    AKDynaRageCompressorParameterAttack,
    AKDynaRageCompressorParameterRelease,
    AKDynaRageCompressorParameterRageAmount,
    AKDynaRageCompressorParameterRageEnabled
};

#ifndef __cplusplus

AKDSPRef createDynaRageCompressorDSP(void);

#endif
