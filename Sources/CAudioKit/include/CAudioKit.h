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

#import "AKDSPBase.h"
#import "AKSoundpipeDSPBase.h"

#import "DSPKernel.h"
#import "ExceptionCatcher.h"
#import "AKGlobals.h"
#import "AUParameterTreeExt.h"

// Testing
#import "DebugDSP.h"

// Analysis
#import "AKPitchTracker.h"

// Effects / Modulation
#import "AKModulatedDelay_Typedefs.h"
#import "AKModulatedDelay.h"
#import "AKModulatedDelayDSP.h"

// Synth example
#import "AKSynthDSP.h"

// Playback
#import "AKPresetManager.h"
#import "AKSampler_Typedefs.h"
#import "AKCoreSampler.h"
#import "AKCoreSynth.h"
#import "AKSamplerDSP.h"

// Utilities
#import "ParameterRamper.h"

// Sequencing / MIDI
#if !TARGET_OS_TV
#import "AKSequencerEngine.h"
#endif

// Automation
#import "AKParameterAutomation.h"
#import "AKLinearParameterRamp.h"

// Swift/ObjC/C/C++ Inter-operability
#import "AKInterop.h"

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

#import "EZAudioPlot.h"
#import "EZAudioFFT.h"
