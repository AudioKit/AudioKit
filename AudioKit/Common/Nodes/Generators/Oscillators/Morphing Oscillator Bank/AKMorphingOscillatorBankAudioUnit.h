//
//  AKMorphingOscillatorBankAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
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
// TODO: New AKPolyphonic method
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity frequency:(float)frequency;

@end

