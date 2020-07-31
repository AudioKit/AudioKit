// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "AKInterop.h"

typedef NS_ENUM(AUParameterAddress, AKDynaRageCompressorParameter) {
    AKDynaRageCompressorParameterRatio,
    AKDynaRageCompressorParameterThreshold,
    AKDynaRageCompressorParameterAttack,
    AKDynaRageCompressorParameterRelease,
    AKDynaRageCompressorParameterRageAmount,
    AKDynaRageCompressorParameterRageEnabled
};

AK_API AKDSPRef createDynaRageCompressorDSP(void);
