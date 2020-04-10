// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import "AKBankAudioUnit.h"

@interface AKOscillatorBankAudioUnit : AKBankAudioUnit

- (void)setupWaveform:(int)size;
- (void)setWaveformValue:(float)value atIndex:(UInt32)index;

- (void)reset;

@end

