// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "AKInterop.h"

typedef NS_ENUM(AUParameterAddress, AKSynthParameter)
{
    // ramped parameters
    
    AKSynthParameterMasterVolume,
    AKSynthParameterPitchBend,
    AKSynthParameterVibratoDepth,
    AKSynthParameterFilterCutoff,
    AKSynthParameterFilterStrength,
    AKSynthParameterFilterResonance,

    // simple parameters

    AKSynthParameterAttackDuration,
    AKSynthParameterDecayDuration,
    AKSynthParameterSustainLevel,
    AKSynthParameterReleaseDuration,
    AKSynthParameterFilterAttackDuration,
    AKSynthParameterFilterDecayDuration,
    AKSynthParameterFilterSustainLevel,
    AKSynthParameterFilterReleaseDuration,

    // ensure this is always last in the list, to simplify parameter addressing
    AKSynthParameterRampDuration,
};

AK_API AKDSPRef akAKSynthCreateDSP(void);
AK_API void akSynthPlayNote(AKDSPRef pDSP, UInt8 noteNumber, UInt8 velocity, float noteFrequency);
AK_API void akSynthStopNote(AKDSPRef pDSP, UInt8 noteNumber, bool immediate);
AK_API void akSynthSustainPedal(AKDSPRef pDSP, bool pedalDown);

#ifdef __cplusplus

#import "AKDSPBase.hpp"
#include "AKCoreSynth.hpp"
#include "AKLinearParameterRamp.hpp"

struct AKSynthDSP : AKDSPBase, AKCoreSynth
{
    // ramped parameters
    AKLinearParameterRamp masterVolumeRamp;
    AKLinearParameterRamp pitchBendRamp;
    AKLinearParameterRamp vibratoDepthRamp;
    AKLinearParameterRamp filterCutoffRamp;
    AKLinearParameterRamp filterStrengthRamp;
    AKLinearParameterRamp filterResonanceRamp;
    
    AKSynthDSP();
    void init(int channelCount, double sampleRate) override;
    void deinit() override;

    void setParameter(uint64_t address, float value, bool immediate) override;
    float getParameter(uint64_t address) override;
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
