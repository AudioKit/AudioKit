//
//  AKSynthDSP.hpp
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

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

#ifndef __cplusplus

AKDSPRef createAKSynthDSP(int channelCount, double sampleRate);
void doAKSynthPlayNote(AKDSPRef pDSP, UInt8 noteNumber, UInt8 velocity, float noteFrequency);
void doAKSynthStopNote(AKDSPRef pDSP, UInt8 noteNumber, bool immediate);
void doAKSynthSustainPedal(AKDSPRef pDSP, bool pedalDown);

#else

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
