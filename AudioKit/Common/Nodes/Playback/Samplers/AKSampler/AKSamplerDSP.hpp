//
//  AKSamplerDSP.hpp
//  ExtendingAudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKSamplerParameter)
{
    // ramped parameters
    masterVolumeParam, pitchBendParam, vibratoDepthParam,
    filterCutoffParam, filterEgStrengthParam, filterResonanceParam,
    // simple parameters
    ampAttackTimeParam, ampDecayTimeParam, ampSustainLevelParam, ampReleaseTimeParam,
    filterAttackTimeParam, filterDecayTimeParam, filterSustainLevelParam, filterReleaseTimeParam,
    filterEnableParam,
    
    // ensure this is always last in the list, to simplify parameter addressing
    rampTimeParam,
};

#ifndef __cplusplus

#include "AKSampler_Typedefs.h"

void* createAKSamplerDSP(int nChannels, double sampleRate);
void doAKSamplerLoadData(void* pDSP, AKSampleDataDescriptor* pSDD);
void doAKSamplerLoadCompressedFile(void* pDSP, AKSampleFileDescriptor* pSFD);
void doAKSamplerUnloadAllSamples(void* pDSP);
void doAKSamplerBuildSimpleKeyMap(void* pDSP);
void doAKSamplerBuildKeyMap(void* pDSP);
void doAKSamplerSetLoopThruRelease(void* pDSP, bool value);
void doAKSamplerPlayNote(void* pDSP, UInt8 noteNumber, UInt8 velocity, float noteHz);
void doAKSamplerStopNote(void* pDSP, UInt8 noteNumber, bool immediate);
void doAKSamplerStopAllVoices(void* pDSP);
void doAKSamplerRestartVoices(void* pDSP);
void doAKSamplerSustainPedal(void* pDSP, bool pedalDown);

#else

#import "AKDSPBase.hpp"
#include "Sampler.hpp"
#include "AKLinearParameterRamp.hpp"

struct AKSamplerDSP : AKDSPBase, AudioKitCore::Sampler
{
    // ramped parameters
    AKLinearParameterRamp masterVolumeRamp;
    AKLinearParameterRamp pitchBendRamp;
    AKLinearParameterRamp vibratoDepthRamp;
    AKLinearParameterRamp filterCutoffRamp;
    AKLinearParameterRamp filterEgStrengthRamp;
    AKLinearParameterRamp filterResonanceRamp;
    
    AKSamplerDSP();
    void init(int nChannels, double sampleRate) override;
    void deinit() override;

    void setParameter(uint64_t address, float value, bool immediate) override;
    float getParameter(uint64_t address) override;
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
