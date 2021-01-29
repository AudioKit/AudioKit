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

#include "DSPBase.h"
#include "SoundpipeDSPBase.h"

#include "ExceptionCatcher.h"
#include "Globals.h"
#include "AUParameterTreeExt.h"

// Testing
#include "DebugDSP.h"

// Analysis
#include "PitchTracker.h"

// Effects / Modulation
#import "ModulatedDelay_Typedefs.h"
#include "ModulatedDelay.h"
#include "ModulatedDelayDSP.h"

// Synth example
#include "SynthDSP.h"

// Playback
#include "PresetManager.h"
#import "Sampler_Typedefs.h"
#if __APPLE__
#import "CoreSampler.h"
#import "CoreSynth.h"
#else // __APPLE__
#include "CoreSampler.h"
#include "CoreSynth.h"
#endif // __APPLE__
#include "SamplerDSP.h"

// Sequencing / MIDI
#include "SequencerEngine.h"

// Automation
#include "ParameterRamper.h"
#include "ParameterAutomation.h"
#include "LinearParameterRamp.h"

// Swift/ObjC/C/C++ Inter-operability
#include "Interop.h"

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
#include "EZAudio.h"
#include "EZAudioPlot.h"
#if __APPLE__
#import "EZAudioFFT.h"
#else // __APPLE__
#include "EZAudioFFT.h"
#endif // __APPLE__

// TPCircularBuffer
#include "TPCircularBuffer+Unit.h"
#include "TPCircularBuffer+AudioBufferList.h"

// Misc
#include "BufferedAudioBus.h"
