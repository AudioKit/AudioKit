// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "AKInterop.h"

typedef NS_ENUM(AUParameterAddress, AKSamplerParameter)
{
    // ramped parameters
    AKSamplerParameterMasterVolume,
    AKSamplerParameterPitchBend,
    AKSamplerParameterVibratoDepth,
    AKSamplerParameterVibratoFrequency,
    AKSamplerParameterVoiceVibratoDepth,
    AKSamplerParameterVoiceVibratoFrequency,
    AKSamplerParameterFilterCutoff,
    AKSamplerParameterFilterStrength,
    AKSamplerParameterFilterResonance,
    AKSamplerParameterGlideRate,

    // simple parameters
    AKSamplerParameterAttackDuration,
    AKSamplerParameterHoldDuration,
    AKSamplerParameterDecayDuration,
    AKSamplerParameterSustainLevel,
    AKSamplerParameterReleaseHoldDuration,
    AKSamplerParameterReleaseDuration,
    AKSamplerParameterFilterAttackDuration,
    AKSamplerParameterFilterDecayDuration,
    AKSamplerParameterFilterSustainLevel,
    AKSamplerParameterFilterReleaseDuration,
    AKSamplerParameterFilterEnable,
    AKSamplerParameterRestartVoiceLFO,
    AKSamplerParameterPitchAttackDuration,
    AKSamplerParameterPitchDecayDuration,
    AKSamplerParameterPitchSustainLevel,
    AKSamplerParameterPitchReleaseDuration,
    AKSamplerParameterPitchADSRSemitones,
    AKSamplerParameterLoopThruRelease,
    AKSamplerParameterMonophonic,
    AKSamplerParameterLegato,
    AKSamplerParameterKeyTrackingFraction,
    AKSamplerParameterFilterEnvelopeVelocityScaling,
    
    // ensure this is always last in the list, to simplify parameter addressing
    AKSamplerParameterRampDuration,
};

#include "AKSampler_Typedefs.h"

AK_API AKDSPRef createAKSamplerDSP(void);
AK_API void doAKSamplerLoadData(AKDSPRef pDSP, AKSampleDataDescriptor *pSDD);
AK_API void doAKSamplerLoadCompressedFile(AKDSPRef pDSP, AKSampleFileDescriptor *pSFD);
AK_API void doAKSamplerUnloadAllSamples(AKDSPRef pDSP);
AK_API void doAKSamplerSetNoteFrequency(AKDSPRef pDSP, int noteNumber, float noteFrequency);
AK_API void doAKSamplerBuildSimpleKeyMap(AKDSPRef pDSP);
AK_API void doAKSamplerBuildKeyMap(AKDSPRef pDSP);
AK_API void doAKSamplerSetLoopThruRelease(AKDSPRef pDSP, bool value);
AK_API void doAKSamplerPlayNote(AKDSPRef pDSP, UInt8 noteNumber, UInt8 velocity);
AK_API void doAKSamplerStopNote(AKDSPRef pDSP, UInt8 noteNumber, bool immediate);
AK_API void doAKSamplerStopAllVoices(AKDSPRef pDSP);
AK_API void doAKSamplerRestartVoices(AKDSPRef pDSP);
AK_API void doAKSamplerSustainPedal(AKDSPRef pDSP, bool pedalDown);

#ifdef __cplusplus

#import "AKDSPBase.hpp"
#include "AKCoreSampler.hpp"
#include "AKLinearParameterRamp.hpp"

struct AKSamplerDSP : AKDSPBase, AKCoreSampler
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
    
    AKSamplerDSP();
    void init(int channelCount, double sampleRate) override;
    void deinit() override;

    void setParameter(uint64_t address, float value, bool immediate) override;
    float getParameter(uint64_t address) override;

    void handleMIDIEvent(AUMIDIEvent const& midiEvent) override;
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
