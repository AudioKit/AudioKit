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

#import "DSPBase.h"
#import "SoundpipeDSPBase.h"

#import "ExceptionCatcher.h"
#import "Globals.h"
#import "AUParameterTreeExt.h"

// Testing
#import "DebugDSP.h"

// Analysis
#import "PitchTracker.h"

// Effects / Modulation
#import "ModulatedDelay_Typedefs.h"
#import "ModulatedDelay.h"
#import "ModulatedDelayDSP.h"

// Synth example
#import "SynthDSP.h"

// Playback
#import "PresetManager.h"
#import "Sampler_Typedefs.h"
#import "CoreSampler.h"
#import "CoreSynth.h"
#import "SamplerDSP.h"

// Utilities
#import "ParameterRamper.h"

// Sequencing / MIDI
#import "SequencerEngine.h"

// Automation
#import "ParameterAutomation.h"
#import "LinearParameterRamp.h"

// Swift/ObjC/C/C++ Inter-operability
#import "Interop.h"

// Custom interop
AK_API void akCombFilterReverbSetLoopDuration(AKDSPRef dsp, float duration);
AK_API void akConvolutionSetPartitionLength(AKDSPRef dsp, int length);
AK_API void akFlatFrequencyResponseSetLoopDuration(AKDSPRef dsp, float duration);
AK_API void akOperationEffectSetSporth(AKDSPRef dspRef, const char *sporth, int length);
AK_API void akOperationGeneratorSetSporth(AKDSPRef dspRef, const char *sporth, int length);
AK_API float* akOperationGeneratorTrigger(AKDSPRef dspRef);
AK_API void akVariableDelaySetMaximumTime(AKDSPRef dsp, float maximumTime);

typedef void (^AKCMIDICallback)(uint8_t, uint8_t, uint8_t);
AK_API void akCallbackInstrumentSetCallback(AKDSPRef dsp, AKCMIDICallback callback);

// Custom debug
#define AKPhaseDistortionOscillatorDebugPhase 0
#define AKOscillatorDebugPhase 0

// EZAudio
#import "EZAudio.h"
#import "EZAudioPlot.h"
#import "EZAudioFFT.h"

// Misc
#import "BufferedAudioBus.h"
