//
//  AKSamplerDSP.hpp
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKSamplerParameter)
{
    // ramped parameters
    AKSamplerParameterMasterVolume,
    AKSamplerParameterPitchBend,
    AKSamplerParameterVibratoDepth,
    AKSamplerParameterFilterCutoff,
    AKSamplerParameterFilterStrength,
    AKSamplerParameterFilterResonance,
    AKSamplerParameterGlideRate,

    // simple parameters
    AKSamplerParameterAttackDuration,
    AKSamplerParameterDecayDuration,
    AKSamplerParameterSustainLevel,
    AKSamplerParameterReleaseDuration,
    AKSamplerParameterFilterAttackDuration,
    AKSamplerParameterFilterDecayDuration,
    AKSamplerParameterFilterSustainLevel,
    AKSamplerParameterFilterReleaseDuration,
    AKSamplerParameterFilterEnable,
    AKSamplerParameterLoopThruRelease,
    AKSamplerParameterMonophonic,
    AKSamplerParameterLegato,
    
    // ensure this is always last in the list, to simplify parameter addressing
    AKSamplerParameterRampDuration,
};

#ifndef __cplusplus

#include "AKSampler_Typedefs.h"

void *createAKSamplerDSP(int nChannels, double sampleRate);
void doAKSamplerLoadData(void *pDSP, AKSampleDataDescriptor *pSDD);
void doAKSamplerLoadCompressedFile(void *pDSP, AKSampleFileDescriptor *pSFD);
void doAKSamplerUnloadAllSamples(void *pDSP);
void doAKSamplerBuildSimpleKeyMap(void *pDSP);
void doAKSamplerBuildKeyMap(void *pDSP);
void doAKSamplerSetLoopThruRelease(void *pDSP, bool value);
void doAKSamplerPlayNote(void *pDSP, UInt8 noteNumber, UInt8 velocity, float noteFrequency);
void doAKSamplerStopNote(void *pDSP, UInt8 noteNumber, bool immediate);
void doAKSamplerStopAllVoices(void *pDSP);
void doAKSamplerRestartVoices(void *pDSP);
void doAKSamplerSustainPedal(void *pDSP, bool pedalDown);

#else

#import "AKDSPBase.hpp"
#include "AKCoreSampler.hpp"
#include "AKLinearParameterRamp.hpp"

struct AKSamplerDSP : AKDSPBase, AKCoreSampler
{
    // ramped parameters
    AKLinearParameterRamp masterVolumeRamp;
    AKLinearParameterRamp pitchBendRamp;
    AKLinearParameterRamp vibratoDepthRamp;
    AKLinearParameterRamp filterCutoffRamp;
    AKLinearParameterRamp filterStrengthRamp;
    AKLinearParameterRamp filterResonanceRamp;
    AKLinearParameterRamp glideRateRamp;
    
    AKSamplerDSP();
    void init(int nChannels, double sampleRate) override;
    void deinit() override;

    void setParameter(uint64_t address, float value, bool immediate) override;
    float getParameter(uint64_t address) override;
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
