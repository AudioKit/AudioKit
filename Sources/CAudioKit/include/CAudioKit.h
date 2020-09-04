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

#import "AKDSPBase.hpp"
#import "AKSoundpipeDSPBase.hpp"

#import "DSPKernel.hpp"
#import "ExceptionCatcher.h"
#import "AKGlobals.hpp"
#import "AUParameterTreeExt.h"

// Testing
#import "md5.h"
#import "DebugDSP.h"

// Analysis
#import "AKPitchTracker.h"

// Effects / Modulation
#import "AKModulatedDelay_Typedefs.h"
#import "AKModulatedDelay.hpp"
#import "AKModulatedDelayDSP.hpp"

// Synth example
#import "AKSynthDSP.hpp"

// Playback
#import "AKPresetManager.h"
#import "AKSampler_Typedefs.h"
#import "AKCoreSampler.hpp"
#import "AKCoreSynth.hpp"
#import "AKSamplerDSP.hpp"

// Utilities
#import "ParameterRamper.hpp"

// Sequencing / MIDI
#if !TARGET_OS_TV
#import "AKSequencerEngine.hpp"
#endif

// Automation
#import "AKParameterAutomation.hpp"
#import "AKLinearParameterRamp.hpp"

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

#import "dr_wav.h"
#import "soundpipe.h"
#import "plumber.h"
