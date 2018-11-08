//
//  AKMorphingOscillatorBankAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#import "AKBankAudioUnit.h"

@interface AKMorphingOscillatorBankAudioUnit : AKBankAudioUnit

@property (nonatomic) float index;

- (void)setupWaveform:(UInt32)waveform size:(int)size;
- (void)setWaveform:(UInt32)waveform withValue:(float)value atIndex:(UInt32)index;
- (void)reset;

@end

