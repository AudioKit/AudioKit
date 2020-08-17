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
#import <AudioKit/AKFrequencyTrackerAudioUnit.h>
#if !TARGET_OS_TV
#import <AudioKit/AKMicrophoneTrackerEngine.h>
#endif

// Sporth
#import <AudioKit/AKOperationGeneratorAudioUnit.h>
#import <AudioKit/AKOperationEffectAudioUnit.h>

// Effects / Modulation
#import <AudioKit/AKModulatedDelay_Typedefs.h>
#import <AudioKit/AKModulatedDelay.hpp>
#import <AudioKit/AKModulatedDelayDSP.hpp>

// Synth example
#import <AudioKit/AKSynthDSP.hpp>

// Playback
#import <AudioKit/AKPresetManager.h>
#import <AudioKit/AKSampler_Typedefs.h>
#import <AudioKit/AKCoreSampler.hpp>
#import <AudioKit/AKCoreSynth.hpp>
#import <AudioKit/AKSamplerDSP.hpp>

// Utilities
#import <AudioKit/ParameterRamper.hpp>

// Sequencing / MIDI
#if !TARGET_OS_TV
#import <AudioKit/AKSequencerEngine.hpp>
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

typedef void (^AKCMIDICallback)(uint8_t, uint8_t, uint8_t);
AK_API void akCallbackInstrumentSetCallback(AKDSPRef dsp, AKCMIDICallback callback);

// Custom debug
#define AKPhaseDistortionOscillatorDebugPhase 0
#define AKOscillatorDebugPhase 0
