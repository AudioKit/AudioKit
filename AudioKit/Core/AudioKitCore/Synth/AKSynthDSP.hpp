//
//  AKSynthDSP.hpp
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKSynthParameter)
{
    // ramped parameters
    
    masterVolumeParameter,
    pitchBendParameter,
    vibratoDepthParameter,
    filterCutoffParameter,
    filterResonanceParameter,

    // simple parameters

    attackDurationParameter,
    decayDurationParameter,
    sustainLevelParameter,
    releaseDurationParameter,

    filterAttackDurationParameter,
    filterDecayDurationParameter,
    filterSustainLevelParameter,
    filterReleaseDurationParameter,
    
    // ensure this is always last in the list, to simplify parameter addressing
    rampDurationParameter,
};

#ifndef __cplusplus

void *AKSynthCreateDSP(int nChannels, double sampleRate);
void AKSynthPlayNote(void *pDSP, UInt8 noteNumber, UInt8 velocity, float noteFrequency);
void AKSynthStopNote(void *pDSP, UInt8 noteNumber, bool immediate);
void AKSynthSustainPedal(void *pDSP, bool pedalDown);

#else

#import "AKDSPBase.hpp"
#include "AKSynth.hpp"
#include "AKLinearParameterRamp.hpp"

struct AKSynthDSP : AKDSPBase, AKSynth
{
    // ramped parameters
    AKLinearParameterRamp masterVolumeRamp;
    AKLinearParameterRamp pitchBendRamp;
    AKLinearParameterRamp vibratoDepthRamp;
    AKLinearParameterRamp filterCutoffRamp;
    AKLinearParameterRamp filterResonanceRamp;
    
    AKSynthDSP();
    void init(int nChannels, double sampleRate) override;
    void deinit() override;

    void setParameter(uint64_t address, float value, bool immediate) override;
    float getParameter(uint64_t address) override;
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
