//
//  AudioKit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

//! Project version number for AudioKit.
FOUNDATION_EXPORT double AudioKitVersionNumber;

//! Project version string for AudioKit.
FOUNDATION_EXPORT const unsigned char AudioKitVersionString[];

// Analysis
#import "AKAmplitudeTrackerAudioUnit.h"
#import "AKFrequencyTrackerAudioUnit.h"

// Effects
#import "AKOperationEffectAudioUnit.h"

// Effects / Delay
#import "AKVariableDelayAudioUnit.h"

// Effects / Distortion
#import "AKBitCrusherAudioUnit.h"
#import "AKClipperAudioUnit.h"
#import "AKTanhDistortionAudioUnit.h"

// Effects / Envelopes
#import "AKAmplitudeEnvelopeAudioUnit.h"
#import "AKTremoloAudioUnit.h"

// Efffects / Filters
#import "AKAutoWahAudioUnit.h"
#import "AKBandPassButterworthFilterAudioUnit.h"
#import "AKBandRejectButterworthFilterAudioUnit.h"
#import "AKCombFilterReverbAudioUnit.h"
#import "AKDCBlockAudioUnit.h"
#import "AKEqualizerFilterAudioUnit.h"
#import "AKHighPassButterworthFilterAudioUnit.h"
#import "AKHighShelfParametricEqualizerFilterAudioUnit.h"
#import "AKKorgLowPassFilterAudioUnit.h"
#import "AKLowPassButterworthFilterAudioUnit.h"
#import "AKLowShelfParametricEqualizerFilterAudioUnit.h"
#import "AKModalResonanceFilterAudioUnit.h"
#import "AKMoogLadderAudioUnit.h"
#import "AKPeakingParametricEqualizerFilterAudioUnit.h"
#import "AKFormantFilterAudioUnit.h"
#import "AKResonantFilterAudioUnit.h"
#import "AKRolandTB303FilterAudioUnit.h"
#import "AKStringResonatorAudioUnit.h"
#import "AKThreePoleLowpassFilterAudioUnit.h"
#import "AKToneComplementFilterAudioUnit.h"
#import "AKToneFilterAudioUnit.h"

// Effects / Pitch Shifter
#import "AKPitchShifterAudioUnit.h"

// Effects / Reverb
#import "AKChowningReverbAudioUnit.h"
#import "AKConvolutionAudioUnit.h"
#import "AKCostelloReverbAudioUnit.h"
#import "AKFlatFrequencyResponseReverbAudioUnit.h"

// Generators
#import "AKOperationGeneratorAudioUnit.h"

// Generators / Noise
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
#import "AKDripAudioUnit.h"
#import "AKFluteAudioUnit.h"
#import "AKMandolinAudioUnit.h"
#import "AKMetalBarAudioUnit.h"
#import "AKPluckedStringAudioUnit.h"
#import "AKClarinetAudioUnit.h"

// Mixing
#import "AKBalancerAudioUnit.h"
#import "AKBoosterAudioUnit.h"
#import "AKPannerAudioUnit.h"
#import "AKStereoFieldLimiterAudioUnit.h"

// Playback
#import "AKPhaseLockedVocoderAudioUnit.h"

// Testing
#import "AKOfflineRenderer.h"
#import "AKTesterAudioUnit.h"

// Plots
#import "EZAudio.h"
