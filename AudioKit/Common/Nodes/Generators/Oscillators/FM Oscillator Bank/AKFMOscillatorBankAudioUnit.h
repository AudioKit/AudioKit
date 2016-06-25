//
//  AKFMOscillatorBankAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKFMOscillatorBankAudioUnit_h
#define AKFMOscillatorBankAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKFMOscillatorBankAudioUnit : AUAudioUnit

@property (nonatomic) float carrierMultiplier;
@property (nonatomic) float modulatingMultiplier;
@property (nonatomic) float modulationIndex;

@property (nonatomic) float attackDuration;
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

#endif /* AKFMOscillatorBankAudioUnit_h */
