// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once
#import "AKBankAudioUnit.h"

@interface AKMorphingOscillatorBankAudioUnit : AKBankAudioUnit

@property (nonatomic) float index;

- (void)setupWaveform:(UInt32)waveform size:(int)size;
- (void)setWaveform:(UInt32)waveform withValue:(float)value atIndex:(UInt32)index;
- (void)reset;

@end

