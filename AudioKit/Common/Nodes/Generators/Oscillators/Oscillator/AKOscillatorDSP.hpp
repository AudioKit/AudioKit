// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "AKInterop.hpp"

typedef NS_ENUM(AUParameterAddress, AKOscillatorParameter) {
    AKOscillatorParameterFrequency,
    AKOscillatorParameterAmplitude,
    AKOscillatorParameterDetuningOffset,
    AKOscillatorParameterDetuningMultiplier,
};

#define AKOscillatorDebugPhase 0

AK_API AKDSPRef createOscillatorDSP(void);
