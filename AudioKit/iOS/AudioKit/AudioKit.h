//
//  AudioKit.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/4/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for AudioKit.
FOUNDATION_EXPORT double AudioKitVersionNumber;

//! Project version string for AudioKit.
FOUNDATION_EXPORT const unsigned char AudioKitVersionString[];

// Analysis
#import <AudioKit/AKAmplitudeTrackerAudioUnit.h>
#import <AudioKit/AKFrequencyTrackerAudioUnit.h>

// Effects
#import <AudioKit/AKOperationEffectAudioUnit.h>

// Effects / Delay
#import <AudioKit/AKVariableDelayAudioUnit.h>

// Effects / Distortion
#import <AudioKit/AKBitCrusherAudioUnit.h>
#import <AudioKit/AKClipperAudioUnit.h>
#import <AudioKit/AKTanhDistortionAudioUnit.h>

// Efffects / Filters
#import <AudioKit/AKAutoWahAudioUnit.h>
#import <AudioKit/AKBandPassButterworthFilterAudioUnit.h>
#import <AudioKit/AKBandRejectButterworthFilterAudioUnit.h>
#import <AudioKit/AKCombFilterAudioUnit.h>
#import <AudioKit/AKDCBlockAudioUnit.h>
#import <AudioKit/AKEqualizerFilterAudioUnit.h>
#import <AudioKit/AKHighPassButterworthFilterAudioUnit.h>
#import <AudioKit/AKHighShelfParametricEqualizerFilterAudioUnit.h>
#import <AudioKit/AKLowPassButterworthFilterAudioUnit.h>
#import <AudioKit/AKLowShelfParametricEqualizerFilterAudioUnit.h>
#import <AudioKit/AKModalResonanceFilterAudioUnit.h>
#import <AudioKit/AKMoogLadderAudioUnit.h>
#import <AudioKit/AKPeakingParametricEqualizerFilterAudioUnit.h>
#import <AudioKit/AKFormantFilterAudioUnit.h>
#import <AudioKit/AKRolandTB303FilterAudioUnit.h>
#import <AudioKit/AKStringResonatorAudioUnit.h>
#import <AudioKit/AKThreePoleLowpassFilterAudioUnit.h>
#import <AudioKit/AKToneComplementFilterAudioUnit.h>
#import <AudioKit/AKToneFilterAudioUnit.h>

// Effects / Reverb
#import <AudioKit/AKChowningReverbAudioUnit.h>
#import <AudioKit/AKCostelloReverbAudioUnit.h>
#import <AudioKit/AKFlatFrequencyResponseReverbAudioUnit.h>

// Generators
#import <AudioKit/AKOperationGeneratorAudioUnit.h>

// Generators / Oscillators
#import <AudioKit/AKFMOscillatorAudioUnit.h>
#import <AudioKit/AKOscillatorAudioUnit.h>
#import <AudioKit/AKSawtoothOscillatorAudioUnit.h>
#import <AudioKit/AKSquareWaveOscillatorAudioUnit.h>
#import <AudioKit/AKTriangleOscillatorAudioUnit.h>

// Generators / Noise
#import <AudioKit/AKPinkNoiseAudioUnit.h>
#import <AudioKit/AKWhiteNoiseAudioUnit.h>

// Mixing
#import <AudioKit/AKBalanceAudioUnit.h>
#import <AudioKit/AKGainAudioUnit.h>

// Testing
#import <AudioKit/AKTesterAudioUnit.h>

// Plots
#import <AudioKit/EZAudio.h>
