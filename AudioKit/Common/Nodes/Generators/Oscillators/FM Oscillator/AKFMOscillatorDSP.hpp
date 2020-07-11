// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKFMOscillatorParameter) {
    AKFMOscillatorParameterBaseFrequency,
    AKFMOscillatorParameterCarrierMultiplier,
    AKFMOscillatorParameterModulatingMultiplier,
    AKFMOscillatorParameterModulationIndex,
    AKFMOscillatorParameterAmplitude,
};

#ifndef __cplusplus

AKDSPRef createFMOscillatorDSP(void);

#endif
