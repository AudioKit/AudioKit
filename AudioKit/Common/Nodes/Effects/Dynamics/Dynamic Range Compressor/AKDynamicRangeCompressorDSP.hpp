// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKDynamicRangeCompressorParameter) {
    AKDynamicRangeCompressorParameterRatio,
    AKDynamicRangeCompressorParameterThreshold,
    AKDynamicRangeCompressorParameterAttackDuration,
    AKDynamicRangeCompressorParameterReleaseDuration,
};

#ifndef __cplusplus

AKDSPRef createDynamicRangeCompressorDSP(void);

#endif
