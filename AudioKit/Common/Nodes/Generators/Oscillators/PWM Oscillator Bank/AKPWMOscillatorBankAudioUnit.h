//
//  AKPWMOscillatorBankAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKPWMOscillatorBankAudioUnit_h
#define AKPWMOscillatorBankAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKPWMOscillatorBankAudioUnit : AUAudioUnit
@property (nonatomic) float pulseWidth;
@property (nonatomic) float attackDuration;
@property (nonatomic) float releaseDuration;
@property (nonatomic) float detuningOffset;
@property (nonatomic) float detuningMultiplier;

- (void)startNote:(int)note velocity:(int)velocity;
- (void)stopNote:(int)note;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKPWMOscillatorBankAudioUnit_h */
