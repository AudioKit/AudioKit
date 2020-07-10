// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKPWMOscillatorParameter) {
    AKPWMOscillatorParameterFrequency,
    AKPWMOscillatorParameterAmplitude,
    AKPWMOscillatorParameterPulseWidth,
    AKPWMOscillatorParameterDetuningOffset,
    AKPWMOscillatorParameterDetuningMultiplier,
};

#ifndef __cplusplus

AKDSPRef createPWMOscillatorDSP(void);

#endif
