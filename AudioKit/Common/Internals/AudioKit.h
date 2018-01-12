//
//  AudioKit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#if !TARGET_OS_TV
#import <CoreAudioKit/CoreAudioKit.h>
#endif

//! Project version number for AudioKit.
FOUNDATION_EXPORT double AudioKitVersionNumber;

//! Project version string for AudioKit.
FOUNDATION_EXPORT const unsigned char AudioKitVersionString[];

#import "AKAudioUnitBase.h"

// Analysis
#import "AKAmplitudeTrackerAudioUnit.h"
#import "AKFrequencyTrackerAudioUnit.h"
#if !TARGET_OS_TV
#import "AKMicrophoneTrackerEngine.h"
#endif

// Effects
#import "AKOperationEffectAudioUnit.h"
#import "AKSporthStack.h"

// Effects / Delay
#import "AKVariableDelayAudioUnit.h"

// Effects / Distortion
#import "AKBitCrusherDSP.hpp"
#import "AKClipperDSP.hpp"
#import "AKTanhDistortionDSP.hpp"

// Effects / Dynamics
#import "AKDynamicRangeCompressorAudioUnit.h"
#import "AKDynaRageCompressorAudioUnit.h"

// Effects / Envelopes
#import "AKAmplitudeEnvelopeAudioUnit.h"
#import "AKTremoloAudioUnit.h"

// Efffects / Filters
#import "AKAutoWahDSP.hpp"
#import "AKBandPassButterworthFilterDSP.hpp"
#import "AKBandRejectButterworthFilterDSP.hpp"
#import "AKCombFilterReverbAudioUnit.h"
#import "AKDCBlockDSP.hpp"
#import "AKEqualizerFilterDSP.hpp"
#import "AKHighPassButterworthFilterDSP.hpp"
#import "AKHighShelfParametricEqualizerFilterDSP.hpp"
#import "AKKorgLowPassFilterAudioUnit.h"
#import "AKLowPassButterworthFilterDSP.hpp"
#import "AKLowShelfParametricEqualizerFilterDSP.hpp"
#import "AKModalResonanceFilterAudioUnit.h"
#import "AKMoogLadderAudioUnit.h"
#import "AKPeakingParametricEqualizerFilterDSP.hpp"
#import "AKFormantFilterAudioUnit.h"
#import "AKResonantFilterAudioUnit.h"
#import "AKRolandTB303FilterAudioUnit.h"
#import "AKStringResonatorAudioUnit.h"
#import "AKThreePoleLowpassFilterAudioUnit.h"
#import "AKToneComplementFilterDSP.hpp"
#import "AKToneFilterDSP.hpp"

// Effects / Guitar Processors
#import "AKRhinoGuitarProcessorAudioUnit.h"

// Effects / Phaser
#import "AKPhaserAudioUnit.h"

// Effects / Pitch Shifter
#import "AKPitchShifterAudioUnit.h"

// Effects / Reverb
#import "AKChowningReverbDSP.hpp"
#import "AKConvolutionAudioUnit.h"
#import "AKCostelloReverbDSP.hpp"
#import "AKFlatFrequencyResponseReverbAudioUnit.h"
#import "AKZitaReverbDSP.hpp"

// Generators
#import "AKOperationGeneratorAudioUnit.h"

// Generators / Noise
#import "AKBrownianNoiseAudioUnit.h"
#import "AKPinkNoiseAudioUnit.h"
#import "AKWhiteNoiseAudioUnit.h"

// Generators / Oscillators
#import "AKFMOscillatorAudioUnit.h"
#import "AKFMOscillatorBankAudioUnit.h"
#import "AKMorphingOscillatorAudioUnit.h"
#import "AKMorphingOscillatorBankAudioUnit.h"
#import "AKOscillatorAudioUnit.h"
#import "AKOscillatorBankAudioUnit.h"
#import "AKPhaseDistortionOscillatorAudioUnit.h"
#import "AKPhaseDistortionOscillatorBankAudioUnit.h"
#import "AKPWMOscillatorAudioUnit.h"
#import "AKPWMOscillatorBankAudioUnit.h"

// Generators / Physical Models
#import "AKClarinetAudioUnit.h"
#import "AKDripAudioUnit.h"
#import "AKFluteAudioUnit.h"
#import "AKMandolinAudioUnit.h"
#import "AKMetalBarAudioUnit.h"
#import "AKPluckedStringAudioUnit.h"
#import "AKRhodesPianoAudioUnit.h"
#import "AKShakerAudioUnit.h"
#import "AKTubularBellsAudioUnit.h"
#import "AKVocalTractAudioUnit.h"

// Mixing
#import "AKBalancerAudioUnit.h"
#import "AKBoosterAudioUnit.h"
#import "AKBoosterDSP.hpp"
#import "AKPannerAudioUnit.h"
#import "AKStereoFieldLimiterAudioUnit.h"

// Playback
#import "AKPhaseLockedVocoderAudioUnit.h"
#import "AKSamplePlayerAudioUnit.h"
#import "AKPresetManager.h"

// Testing
#import "AKTesterAudioUnit.h"

// EZAudio
#import "EZAudio.h"

// Offline
#import "AKOfflineRenderAudioUnit.h"

// Taps
#import "AKRenderTap.h"
#import "AKLazyTap.h"
#import "AKTimelineTap.h"

// Utilities
#import "TPCircularBuffer.h"
#import "TPCircularBuffer+Unit.h"
#import "TPCircularBuffer+AudioBufferList.h"
#import "AKTimeline.h"

// Sequencer
#import "AKSamplerMetronome.h"

// Swift/ObjC/C/C++ Inter-operability
#import "AKInterop.h"
