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

AK_API DSPRef akSynthCreateDSP(void);

#ifdef __cplusplus

#import "DSPBase.h"
#include "CoreSynth.h"
#include "LinearParameterRamp.h"

struct SynthDSP : DSPBase, CoreSynth
{
    // ramped parameters
    LinearParameterRamp masterVolumeRamp;
    LinearParameterRamp pitchBendRamp;
    LinearParameterRamp vibratoDepthRamp;
    LinearParameterRamp filterCutoffRamp;
    LinearParameterRamp filterStrengthRamp;
    LinearParameterRamp filterResonanceRamp;
    
    SynthDSP();
    void init(int channelCount, double sampleRate) override;
    void deinit() override;

    void setParameter(uint64_t address, float value, bool immediate) override;
    float getParameter(uint64_t address) override;

    void handleMIDIEvent(const AUMIDIEvent &midiEvent) override;
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
