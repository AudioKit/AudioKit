// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKOscillatorParameter) {
    AKOscillatorParameterFrequency,
    AKOscillatorParameterAmplitude,
    AKOscillatorParameterDetuningOffset,
    AKOscillatorParameterDetuningMultiplier,
};

#ifndef __cplusplus

AKDSPRef createOscillatorDSP(void);

#endif
