//
//  AKOscillatorBankAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKOscillatorBankAudioUnit_h
#define AKOscillatorBankAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKOscillatorBankAudioUnit : AUAudioUnit
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

#endif /* AKOscillatorBankAudioUnit_h */
