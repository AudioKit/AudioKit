// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#if !TARGET_OS_TV
#import <CoreAudioKit/CoreAudioKit.h>
#endif

//! Project version number for AudioKit.
FOUNDATION_EXPORT double AudioKitVersionNumber;

//! Project version string for AudioKit.
FOUNDATION_EXPORT const unsigned char AudioKitVersionString[];

#import <AudioKit/AKDSPBase.hpp>
#import <AudioKit/AKSoundpipeDSPBase.hpp>
#import <AudioKit/DSPKernel.hpp>
#import <AudioKit/AKDSPKernel.hpp>
#import <AudioKit/AKSoundpipeKernel.hpp>
#import <AudioKit/AKBankDSPKernel.hpp>
#import <AudioKit/AKFilterSynthDSPKernel.hpp>
#import <AudioKit/ExceptionCatcher.h>
#import <AudioKit/AKGlobals.hpp>

// Analysis
#import <AudioKit/AKAmplitudeTrackerAudioUnit.h>
#import <AudioKit/AKFrequencyTrackerAudioUnit.h>
#if !TARGET_OS_TV
#import <AudioKit/AKMicrophoneTrackerEngine.h>
#endif

// Effects
#import <AudioKit/AKOperationEffectAudioUnit.h>
#import <AudioKit/AKSporthStack.h>

// Effects / Delay
#import <AudioKit/AKVariableDelayDSP.hpp>
#import <AudioKit/AKStereoDelayDSP.hpp>

// Effects / Distortion
#import <AudioKit/AKBitCrusherDSP.hpp>
#import <AudioKit/AKClipperDSP.hpp>
#import <AudioKit/AKTanhDistortionDSP.hpp>

// Effects / Dynamics
#import <AudioKit/AKDynamicRangeCompressorDSP.hpp>

// Effects / Envelopes
#import <AudioKit/AKAmplitudeEnvelopeDSP.hpp>
#import <AudioKit/AKTremoloDSP.hpp>

// Effects / Filters
#import <AudioKit/AKAutoWahDSP.hpp>
#import <AudioKit/AKBandPassButterworthFilterDSP.hpp>
#import <AudioKit/AKBandRejectButterworthFilterDSP.hpp>
#import <AudioKit/AKDCBlockDSP.hpp>
#import <AudioKit/AKEqualizerFilterDSP.hpp>
#import <AudioKit/AKFormantFilterDSP.hpp>
#import <AudioKit/AKHighPassButterworthFilterDSP.hpp>
#import <AudioKit/AKHighShelfParametricEqualizerFilterDSP.hpp>
#import <AudioKit/AKKorgLowPassFilterDSP.hpp>
#import <AudioKit/AKLowPassButterworthFilterDSP.hpp>
#import <AudioKit/AKLowShelfParametricEqualizerFilterDSP.hpp>
#import <AudioKit/AKModalResonanceFilterDSP.hpp>
#import <AudioKit/AKMoogLadderDSP.hpp>
#import <AudioKit/AKPeakingParametricEqualizerFilterDSP.hpp>
#import <AudioKit/AKResonantFilterDSP.hpp>
#import <AudioKit/AKRolandTB303FilterDSP.hpp>
#import <AudioKit/AKStringResonatorDSP.hpp>
#import <AudioKit/AKThreePoleLowpassFilterDSP.hpp>
#import <AudioKit/AKToneComplementFilterDSP.hpp>
#import <AudioKit/AKToneFilterDSP.hpp>

// Effects / Modulation
#import <AudioKit/AKModulatedDelay_Typedefs.h>
#import <AudioKit/AKModulatedDelay.hpp>
#import <AudioKit/AKModulatedDelayDSP.hpp>
#import <AudioKit/AKPhaserDSP.hpp>

// Effects / Pitch Shifter
#import <AudioKit/AKPitchShifterDSP.hpp>

// Effects / Reverb
#import <AudioKit/AKChowningReverbDSP.hpp>
#import <AudioKit/AKCombFilterReverbDSP.hpp>
#import <AudioKit/AKConvolutionDSP.hpp>
#import <AudioKit/AKCostelloReverbDSP.hpp>
#import <AudioKit/AKFlatFrequencyResponseReverbDSP.hpp>
#import <AudioKit/AKZitaReverbDSP.hpp>

// Generators
#import <AudioKit/AKOperationGeneratorAudioUnit.h>

// Generators / Noise
#import <AudioKit/AKBrownianNoiseDSP.hpp>
#import <AudioKit/AKPinkNoiseDSP.hpp>
#import <AudioKit/AKWhiteNoiseDSP.hpp>

// Generators / Oscillators
#import <AudioKit/AKFMOscillatorDSP.hpp>
#import <AudioKit/AKMorphingOscillatorDSP.hpp>
#import <AudioKit/AKOscillatorDSP.hpp>
#import <AudioKit/AKPhaseDistortionOscillatorDSP.hpp>
#import <AudioKit/AKPWMOscillatorDSP.hpp>

// Generators / Physical Models
#import <AudioKit/AKDripDSP.hpp>
#import <AudioKit/AKMetalBarDSP.hpp>
#import <AudioKit/AKPluckedStringDSP.hpp>
#import <AudioKit/AKVocalTractDSP.hpp>

// Generators / Polysynths
#import <AudioKit/AKFMOscillatorBankAudioUnit.h>
#import <AudioKit/AKMorphingOscillatorBankAudioUnit.h>
#import <AudioKit/AKOscillatorBankAudioUnit.h>
#import <AudioKit/AKPhaseDistortionOscillatorBankAudioUnit.h>
#import <AudioKit/AKPWMOscillatorBankAudioUnit.h>
#import <AudioKit/AKSynthDSP.hpp>

// Generators / Filter Polysynths
#import <AudioKit/AKFMOscillatorFilterSynthAudioUnit.h>
#import <AudioKit/AKMorphingOscillatorFilterSynthAudioUnit.h>
#import <AudioKit/AKOscillatorFilterSynthAudioUnit.h>
#import <AudioKit/AKPhaseDistortionOscillatorFilterSynthAudioUnit.h>
#import <AudioKit/AKPWMOscillatorFilterSynthAudioUnit.h>

// Mixing
#import <AudioKit/AKAutoPannerDSP.hpp>
#import <AudioKit/AKBalancerDSP.hpp>
#import <AudioKit/AKBoosterDSP.hpp>
#import <AudioKit/AKFaderDSP.hpp>
#import <AudioKit/AKPannerDSP.hpp>
#import <AudioKit/AKStereoFieldLimiterDSP.hpp>

// Playback
#import <AudioKit/AKPhaseLockedVocoderDSP.hpp>
#import <AudioKit/AKWaveTableAudioUnit.h>
#import <AudioKit/AKDiskStreamerAudioUnit.h>
#import <AudioKit/AKPresetManager.h>
#import <AudioKit/AKSampler_Typedefs.h>
#import <AudioKit/AKCoreSampler.hpp>
#import <AudioKit/AKCoreSynth.hpp>
#import <AudioKit/AKSamplerDSP.hpp>

#if !TARGET_OS_TV
#import <AudioKit/AKCallbackInstrumentAudioUnit.h>
#endif

// Testing
#import <AudioKit/AKTesterAudioUnit.h>

// EZAudio
#import <AudioKit/EZAudio.h>

// Taps
#import <AudioKit/AKRenderTap.h>
#import <AudioKit/AKLazyTap.h>
#import <AudioKit/AKTimelineTap.h>

// Utilities
#import <AudioKit/TPCircularBuffer.h>
#import <AudioKit/TPCircularBuffer+Unit.h>
#import <AudioKit/TPCircularBuffer+AudioBufferList.h>
#import <AudioKit/ParameterRamper.hpp>
#import <AudioKit/BufferedAudioBus.hpp>
#import <AudioKit/AKTimeline.h>

// Sequencer
#import <AudioKit/AKSamplerMetronome.h>
#if !TARGET_OS_TV
#import <AudioKit/AKSequencerEngineDSP.hpp>
#endif

// Swift/ObjC/C/C++ Inter-operability
#import <AudioKit/AKInterop.hpp>

// Automation
#import <AudioKit/AKParameterAutomation.hpp>
#import <AudioKit/AKLinearParameterRamp.hpp>
