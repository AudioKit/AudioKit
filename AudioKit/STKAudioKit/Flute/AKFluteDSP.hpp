// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKFluteParameter) {
    AKFluteParameterFrequency,
    AKFluteParameterAmplitude,
    AKFluteParameterRampDuration
};

#ifndef __cplusplus

AKDSPRef createFluteDSP(void);

#endif

