//
//  SynthDSP.hpp
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, SynthParameter)
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

void *createSynthDSP(int nChannels, double sampleRate);
void doSynthPlayNote(void *pDSP, UInt8 noteNumber, UInt8 velocity, float noteHz);
void doSynthStopNote(void *pDSP, UInt8 noteNumber, bool immediate);
void doSynthSustainPedal(void *pDSP, bool pedalDown);

#else

#import "AKDSPBase.hpp"
#include "Synth.hpp"
#include "AKLinearParameterRamp.hpp"

struct SynthDSP : AKDSPBase, AudioKitCore::Synth
{
    // ramped parameters
    AKLinearParameterRamp masterVolumeRamp;
    AKLinearParameterRamp pitchBendRamp;
    AKLinearParameterRamp vibratoDepthRamp;
    AKLinearParameterRamp filterCutoffRamp;
    AKLinearParameterRamp filterResonanceRamp;
    
    SynthDSP();
    void init(int nChannels, double sampleRate) override;
    void deinit() override;

    void setParameter(uint64_t address, float value, bool immediate) override;
    float getParameter(uint64_t address) override;
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
