//
//  AKMorphingOscillatorBankAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKMorphingOscillatorBankAudioUnit : AKAudioUnit

@property (nonatomic) float index;

@property (nonatomic) float attackDuration;
@property (nonatomic) float decayDuration;
@property (nonatomic) float sustainLevel;
@property (nonatomic) float releaseDuration;
@property (nonatomic) float detuningOffset;
@property (nonatomic) float detuningMultiplier;

- (void)setupWaveform:(UInt32)waveform size:(int)size;
- (void)setWaveform:(UInt32)waveform withValue:(float)value atIndex:(UInt32)index;
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity;
- (void)stopNote:(uint8_t)note;
//TODO: Example of new AKPolyphonic method
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity frequency:(float)frequency;

//TODO: Aure:

//I recommend an optional protocol for some AKAudioUnit subclasses...something like:
//- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity frequency:(float)frequency;
//- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity;
//- (void)stopNote:(uint8_t)note;

// or, if you don't want these classes to appear to know about midi you could go this way:
//-(void)setFrequency:(float)frequency
// This approach minimizes the implementation at the c++ level, keeps it at the Swift level.



// classes that would certainly benefit from adopting this new protocol:
//AKMorphingOscillatorBankAudioUnit
//AKClarinetAudioUnit
//AKFluteAudioUnit
//AKFMOscillatorAudioUnit
//AKFMOscillatorBankAudioUnit
//AKMandolinAudioUnit
//AKOscillatorAudioUnit
//AKOscillatorBankAudioUnit
//AKPhaseDistortionOscillatorAudioUnit
//AKPhaseDistortionOscillatorBankAudioUnit
//AKPluckedStringAudioUnit
//AKPWMOscillatorAudioUnit
//AKPWMOscillatorBankAudioUnit

// these classes are more work...could leave them for later
//AKBandPassButterworthFilterAudioUnit
//AKBandRejectButterworthFilterAudioUnit
//AKCostelloReverbAudioUnit
//AKEqualizerFilterAudioUnit
//AKHighPassButterworthFilterAudioUnit
//AKKorgLowPassFilterAudioUnit
//AKLowPassButterworthFilterAudioUnit
//AKLowShelfParametricEqualizerFilterAudioUnit
//AKModalResonanceFilterAudioUnit
//AKMoogLadderAudioUnit
//AKMorphingOscillatorAudioUnit
//AKMorphingOscillatorBankAudioUnit
//AKPeakingParametricEqualizerFilterAudioUnit
//AKResonantFilterAudioUnit
//AKRolandTB303FilterAudioUnit
//AKStringResonatorAudioUnit
//AKThreePoleLowpassFilterAudioUnit
//AKTremoloAudioUnit



@end

