//
//  AKFMOscillatorBankAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AKAudioUnit.h"

@interface AKFMOscillatorBankAudioUnit : AKAudioUnit

@property (nonatomic) float carrierMultiplier;
@property (nonatomic) float modulatingMultiplier;
@property (nonatomic) float modulationIndex;

@property (nonatomic) float attackDuration;
@property (nonatomic) float decayDuration;
@property (nonatomic) float sustainLevel;
@property (nonatomic) float releaseDuration;
@property (nonatomic) float detuningOffset;
@property (nonatomic) float detuningMultiplier;

- (void)setupWaveform:(int)size;
- (void)setWaveformValue:(float)value atIndex:(UInt32)index;
//TODO: Add new AKPolyphonic method
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity;
- (void)stopNote:(uint8_t)note;

@end
