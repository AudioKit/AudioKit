// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKWhiteNoiseParameter) {
    AKWhiteNoiseParameterAmplitude,
};

#ifndef __cplusplus

AKDSPRef createWhiteNoiseDSP(void);

#endif
