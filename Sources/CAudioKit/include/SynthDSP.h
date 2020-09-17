// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "Interop.h"

typedef NS_ENUM(AUParameterAddress, SynthParameter)
{
    // ramped parameters
    
    SynthParameterMasterVolume,
    SynthParameterPitchBend,
    SynthParameterVibratoDepth,
    SynthParameterFilterCutoff,
    SynthParameterFilterStrength,
    SynthParameterFilterResonance,

    // simple parameters

    SynthParameterAttackDuration,
    SynthParameterDecayDuration,
    SynthParameterSustainLevel,
    SynthParameterReleaseDuration,
    SynthParameterFilterAttackDuration,
    SynthParameterFilterDecayDuration,
    SynthParameterFilterSustainLevel,
    SynthParameterFilterReleaseDuration,

    // ensure this is always last in the list, to simplify parameter addressing
    SynthParameterRampDuration,
};

AK_API AKDSPRef akSynthCreateDSP(void);
AK_API void akSynthPlayNote(AKDSPRef pDSP, UInt8 noteNumber, UInt8 velocity, float noteFrequency);
AK_API void akSynthStopNote(AKDSPRef pDSP, UInt8 noteNumber, bool immediate);
AK_API void akSynthSustainPedal(AKDSPRef pDSP, bool pedalDown);

#ifdef __cplusplus

#import "DSPBase.h"
#include "CoreSynth.h"
#include "LinearParameterRamp.h"

struct SynthDSP : AKDSPBase, CoreSynth
{
    // ramped parameters
    AKLinearParameterRamp masterVolumeRamp;
    AKLinearParameterRamp pitchBendRamp;
    AKLinearParameterRamp vibratoDepthRamp;
    AKLinearParameterRamp filterCutoffRamp;
    AKLinearParameterRamp filterStrengthRamp;
    AKLinearParameterRamp filterResonanceRamp;
    
    SynthDSP();
    void init(int channelCount, double sampleRate) override;
    void deinit() override;

    void setParameter(uint64_t address, float value, bool immediate) override;
    float getParameter(uint64_t address) override;
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
