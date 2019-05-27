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
    AKSamplerParameterKeyTrackingFraction,
    AKSamplerParameterFilterEnvelopeVelocityScaling,
    
    // ensure this is always last in the list, to simplify parameter addressing
    AKSamplerParameterRampDuration,
};

#ifndef __cplusplus

#include "AKSampler_Typedefs.h"

AKDSPRef createAKSamplerDSP(int channelCount, double sampleRate);
void doAKSamplerLoadData(AKDSPRef pDSP, AKSampleDataDescriptor *pSDD);
void doAKSamplerLoadCompressedFile(AKDSPRef pDSP, AKSampleFileDescriptor *pSFD);
void doAKSamplerUnloadAllSamples(AKDSPRef pDSP);
void doAKSamplerSetNoteFrequency(AKDSPRef pDSP, int noteNumber, float noteFrequency);
void doAKSamplerBuildSimpleKeyMap(AKDSPRef pDSP);
void doAKSamplerBuildKeyMap(AKDSPRef pDSP);
void doAKSamplerSetLoopThruRelease(AKDSPRef pDSP, bool value);
void doAKSamplerPlayNote(AKDSPRef pDSP, UInt8 noteNumber, UInt8 velocity, float noteFrequency);
void doAKSamplerStopNote(AKDSPRef pDSP, UInt8 noteNumber, bool immediate);
void doAKSamplerStopAllVoices(AKDSPRef pDSP);
void doAKSamplerRestartVoices(AKDSPRef pDSP);
void doAKSamplerSustainPedal(AKDSPRef pDSP, bool pedalDown);

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
    void init(int channelCount, double sampleRate) override;
    void deinit() override;

    void setParameter(uint64_t address, float value, bool immediate) override;
    float getParameter(uint64_t address) override;

    void handleMIDIEvent(AUMIDIEvent const& midiEvent) override;
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
