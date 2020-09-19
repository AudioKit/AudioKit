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
#import "TapNode.h"

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
AK_API void akCombFilterReverbSetLoopDuration(DSPRef dsp, float duration);
AK_API void akConvolutionSetPartitionLength(DSPRef dsp, int length);
AK_API void akFlatFrequencyResponseSetLoopDuration(DSPRef dsp, float duration);
AK_API void akOperationEffectSetSporth(DSPRef dspRef, const char *sporth, int length);
AK_API void akOperationGeneratorSetSporth(DSPRef dspRef, const char *sporth, int length);
AK_API float* akOperationGeneratorTrigger(DSPRef dspRef);
AK_API void akVariableDelaySetMaximumTime(DSPRef dsp, float maximumTime);

typedef void (^CMIDICallback)(uint8_t, uint8_t, uint8_t);
AK_API void akCallbackInstrumentSetCallback(DSPRef dsp, CMIDICallback callback);

// Custom debug
#define PhaseDistortionOscillatorDebugPhase 0
#define OscillatorDebugPhase 0

// EZAudio
#import "EZAudio.h"
#import "EZAudioPlot.h"
#import "EZAudioFFT.h"

// Misc
#import "BufferedAudioBus.h"
