// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#if !TARGET_OS_TV
#import <CoreAudioKit/CoreAudioKit.h>
#endif
#import <AudioKit/EZAudio.h>

//! Project version number for AudioKit.
FOUNDATION_EXPORT double AudioKitVersionNumber;

//! Project version string for AudioKit.
FOUNDATION_EXPORT const unsigned char AudioKitVersionString[];

#import <AudioKit/AKDSPBase.hpp>
#import <AudioKit/AKSoundpipeDSPBase.hpp>

#import <AudioKit/DSPKernel.hpp>
#import <AudioKit/ExceptionCatcher.h>
#import <AudioKit/AKGlobals.hpp>

#import <AudioKit/AKParameterRamp.hpp>

// Testing
#import <AudioKit/md5.h>
#import <AudioKit/DebugDSP.h>

// Analysis
#import <AudioKit/AKAmplitudeTrackerAudioUnit.h>
#import <AudioKit/AKFrequencyTrackerAudioUnit.h>
#if !TARGET_OS_TV
#import <AudioKit/AKMicrophoneTrackerEngine.h>
#endif

// Sporth
#import <AudioKit/AKOperationGeneratorAudioUnit.h>
#import <AudioKit/AKOperationEffectAudioUnit.h>
#import <AudioKit/AKSporthStack.h>

// Effects / Modulation
#import <AudioKit/AKModulatedDelay_Typedefs.h>
#import <AudioKit/AKModulatedDelay.hpp>
#import <AudioKit/AKModulatedDelayDSP.hpp>

// Synth example
#import <AudioKit/AKSynthDSP.hpp>

// Playback
#import <AudioKit/AKWaveTableAudioUnit.h>
#import <AudioKit/AKDiskStreamerAudioUnit.h>
#import <AudioKit/AKPresetManager.h>
#import <AudioKit/AKSampler_Typedefs.h>
#import <AudioKit/AKCoreSampler.hpp>
#import <AudioKit/AKCoreSynth.hpp>
#import <AudioKit/AKSamplerDSP.hpp>

// Taps
#import <AudioKit/AKRenderTap.h>
#import <AudioKit/AKLazyTap.h>
#import <AudioKit/AKTimelineTap.h>

// Utilities
#import <AudioKit/ParameterRamper.hpp>
#import <AudioKit/AKTimeline.h>

// Sequencing / MIDI
#import <AudioKit/AKSamplerMetronome.h>
#if !TARGET_OS_TV
#import <AudioKit/AKSequencerEngine.hpp>
#import <AudioKit/AKCallbackInstrumentAudioUnit.h>
#endif

// Automation
#import <AudioKit/AKParameterAutomation.hpp>
#import <AudioKit/AKLinearParameterRamp.hpp>

// Swift/ObjC/C/C++ Inter-operability
#import <AudioKit/AKInterop.h>

// Custom interop
AK_API void akCombFilterReverbSetLoopDuration(AKDSPRef dsp, float duration);
AK_API void akConvolutionSetPartitionLength(AKDSPRef dsp, int length);
AK_API void akFlatFrequencyResponseSetLoopDuration(AKDSPRef dsp, float duration);
AK_API void akVariableDelaySetMaximumTime(AKDSPRef dsp, float maximumTime);

// Custom debug
#define AKPhaseDistortionOscillatorDebugPhase 0
#define AKOscillatorDebugPhase 0
