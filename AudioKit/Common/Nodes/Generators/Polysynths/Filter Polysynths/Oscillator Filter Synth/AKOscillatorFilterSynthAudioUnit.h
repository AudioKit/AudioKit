//
//  AKOscillatorFilterSynthAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import "AKFilterSynthAudioUnit.h"

@interface AKOscillatorFilterSynthAudioUnit : AKFilterSynthAudioUnit

- (void)setupWaveform:(int)size;
- (void)setWaveformValue:(float)value atIndex:(UInt32)index;

- (void)reset;

@end

