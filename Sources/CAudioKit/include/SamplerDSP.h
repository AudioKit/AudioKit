// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "Interop.h"

typedef NS_ENUM(AUParameterAddress, SamplerParameter)
{
    // ramped parameters
    SamplerParameterMasterVolume,
    SamplerParameterPitchBend,
    SamplerParameterVibratoDepth,
    SamplerParameterVibratoFrequency,
    SamplerParameterVoiceVibratoDepth,
    SamplerParameterVoiceVibratoFrequency,
    SamplerParameterFilterCutoff,
    SamplerParameterFilterStrength,
    SamplerParameterFilterResonance,
    SamplerParameterGlideRate,

    // simple parameters
    SamplerParameterAttackDuration,
    SamplerParameterHoldDuration,
    SamplerParameterDecayDuration,
    SamplerParameterSustainLevel,
    SamplerParameterReleaseHoldDuration,
    SamplerParameterReleaseDuration,
    SamplerParameterFilterAttackDuration,
    SamplerParameterFilterDecayDuration,
    SamplerParameterFilterSustainLevel,
    SamplerParameterFilterReleaseDuration,
    SamplerParameterFilterEnable,
    SamplerParameterRestartVoiceLFO,
    SamplerParameterPitchAttackDuration,
    SamplerParameterPitchDecayDuration,
    SamplerParameterPitchSustainLevel,
    SamplerParameterPitchReleaseDuration,
    SamplerParameterPitchADSRSemitones,
    SamplerParameterLoopThruRelease,
    SamplerParameterMonophonic,
    SamplerParameterLegato,
    SamplerParameterKeyTrackingFraction,
    SamplerParameterFilterEnvelopeVelocityScaling,
    
    // ensure this is always last in the list, to simplify parameter addressing
    SamplerParameterRampDuration,
};

#include "Sampler_Typedefs.h"

AK_API AKDSPRef akSamplerCreateDSP(void);
AK_API void akSamplerLoadData(AKDSPRef pDSP, SampleDataDescriptor *pSDD);
AK_API void akSamplerLoadCompressedFile(AKDSPRef pDSP, SampleFileDescriptor *pSFD);
AK_API void akSamplerUnloadAllSamples(AKDSPRef pDSP);
AK_API void akSamplerSetNoteFrequency(AKDSPRef pDSP, int noteNumber, float noteFrequency);
AK_API void akSamplerBuildSimpleKeyMap(AKDSPRef pDSP);
AK_API void akSamplerBuildKeyMap(AKDSPRef pDSP);
AK_API void akSamplerSetLoopThruRelease(AKDSPRef pDSP, bool value);
AK_API void akSamplerPlayNote(AKDSPRef pDSP, UInt8 noteNumber, UInt8 velocity);
AK_API void akSamplerStopNote(AKDSPRef pDSP, UInt8 noteNumber, bool immediate);
AK_API void akSamplerStopAllVoices(AKDSPRef pDSP);
AK_API void akSamplerRestartVoices(AKDSPRef pDSP);
AK_API void akSamplerSustainPedal(AKDSPRef pDSP, bool pedalDown);

#ifdef __cplusplus

#import "DSPBase.h"
#include "CoreSampler.h"
#include "LinearParameterRamp.h"

struct SamplerDSP : AKDSPBase, CoreSampler
{
    // ramped parameters
    AKLinearParameterRamp masterVolumeRamp;
    AKLinearParameterRamp pitchBendRamp;
    AKLinearParameterRamp vibratoDepthRamp;
    AKLinearParameterRamp vibratoFrequencyRamp;
    AKLinearParameterRamp voiceVibratoDepthRamp;
    AKLinearParameterRamp voiceVibratoFrequencyRamp;
    AKLinearParameterRamp filterCutoffRamp;
    AKLinearParameterRamp filterStrengthRamp;
    AKLinearParameterRamp filterResonanceRamp;
    AKLinearParameterRamp pitchADSRSemitonesRamp;
    AKLinearParameterRamp glideRateRamp;
    
    SamplerDSP();
    void init(int channelCount, double sampleRate) override;
    void deinit() override;

    void setParameter(uint64_t address, float value, bool immediate) override;
    float getParameter(uint64_t address) override;

    void handleMIDIEvent(AUMIDIEvent const& midiEvent) override;
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
