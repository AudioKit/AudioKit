//
//  AKSamplerDSP.hpp
//  ExtendingAudioKit
//
//  Created by Shane Dunne on 2018-02-19.
//  Copyright © 2018 Shane Dunne & Associates. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKSamplerParameter)
{
    // ramped parameters
    pitchBendParam, vibratoDepthParam,
    // simple parameters
    ampAttackTimeParam, ampDecayTimeParam, ampSustainLevelParam, ampReleaseTimeParam,
    filterAttackTimeParam, filterDecayTimeParam, filterSustainLevelParam, filterReleaseTimeParam,
    filterEnableParam,
    
    // ensure this is always last in the list, to simplify parameter addressing
    rampTimeParam,
};

#ifndef __cplusplus

void* createAKSamplerDSP(int nChannels, double sampleRate);
void doAKSamplerLoadData(void* pDSP, UInt8 noteNumber, float noteHz, bool bInterleaved,
                         unsigned nChannelCount, unsigned nSampleCount, float *pData,
                         int min_note, int max_note, int min_vel, int max_vel,
                         bool bLoop, float fLoopStart, float fLoopEnd, float fStart, float fEnd);
void doAKSamplerBuildSimpleKeyMap(void* pDSP);
void doAKSamplerBuildKeyMap(void* pDSP);
void doAKSamplerPlayNote(void* pDSP, UInt8 noteNumber, UInt8 velocity, float noteHz);
void doAKSamplerStopNote(void* pDSP, UInt8 noteNumber, bool immediate);

#else

#import "AKDSPBase.hpp"
#include "AKSampler.h"
#include "AKLinearParameterRamp.hpp"

struct AKSamplerDSP : AKDSPBase, AKSampler
{
    // ramped parameters
    AKLinearParameterRamp pitchBendRamp;
    AKLinearParameterRamp vibratoDepthRamp;
    
    AKSamplerDSP();
    void init(int nChannels, double sampleRate) override;
    void deinit() override;

    void setParameter(uint64_t address, float value, bool immediate) override;
    float getParameter(uint64_t address) override;
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
