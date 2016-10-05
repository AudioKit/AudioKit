//
//  AKPhaseDistortionOscillatorBankAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKPhaseDistortionOscillatorBankAudioUnit_h
#define AKPhaseDistortionOscillatorBankAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKPhaseDistortionOscillatorBankAudioUnit : AUAudioUnit

@property (nonatomic) float phaseDistortion;

@property (nonatomic) float attackDuration;
@property (nonatomic) float decayDuration;
@property (nonatomic) float sustainLevel;
@property (nonatomic) float releaseDuration;
@property (nonatomic) float detuningOffset;
@property (nonatomic) float detuningMultiplier;

- (void)setupWaveform:(int)size;
- (void)setWaveformValue:(float)value atIndex:(UInt32)index;
- (void)startNote:(int)note velocity:(int)velocity;
- (void)stopNote:(int)note;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKPhaseDistortionOscillatorBankAudioUnit_h */
