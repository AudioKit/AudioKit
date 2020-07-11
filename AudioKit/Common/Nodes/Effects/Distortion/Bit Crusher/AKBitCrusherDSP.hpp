// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKBitCrusherParameter) {
    AKBitCrusherParameterBitDepth,
    AKBitCrusherParameterSampleRate,
};

#ifndef __cplusplus

AKDSPRef createBitCrusherDSP(void);

#endif
