//
//  AKPWMOscillatorBankAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKPWMOscillatorBankAudioUnit_h
#define AKPWMOscillatorBankAudioUnit_h

#import "AKAudioUnit.h"

@interface AKPWMOscillatorBankAudioUnit : AKAudioUnit
@property (nonatomic) float pulseWidth;
@property (nonatomic) float attackDuration;
@property (nonatomic) float decayDuration;
@property (nonatomic) float sustainLevel;
@property (nonatomic) float releaseDuration;
@property (nonatomic) float detuningOffset;
@property (nonatomic) float detuningMultiplier;

- (void)startNote:(int)note velocity:(int)velocity;
- (void)stopNote:(int)note;

@end

#endif /* AKPWMOscillatorBankAudioUnit_h */
