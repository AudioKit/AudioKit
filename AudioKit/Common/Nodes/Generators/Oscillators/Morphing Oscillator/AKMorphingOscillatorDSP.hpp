// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKMorphingOscillatorParameter) {
    AKMorphingOscillatorParameterFrequency,
    AKMorphingOscillatorParameterAmplitude,
    AKMorphingOscillatorParameterIndex,
    AKMorphingOscillatorParameterDetuningOffset,
    AKMorphingOscillatorParameterDetuningMultiplier,
};

#ifndef __cplusplus

AKDSPRef createMorphingOscillatorDSP(void);

#endif
