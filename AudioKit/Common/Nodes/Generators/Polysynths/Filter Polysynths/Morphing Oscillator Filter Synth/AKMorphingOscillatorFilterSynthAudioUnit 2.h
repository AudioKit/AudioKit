//
//  AKMorphingOscillatorFilterSynthAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#import "AKFilterSynthAudioUnit.h"

@interface AKMorphingOscillatorFilterSynthAudioUnit : AKFilterSynthAudioUnit

@property (nonatomic) float index;

- (void)setupWaveform:(UInt32)waveform size:(int)size;
- (void)setWaveform:(UInt32)waveform withValue:(float)value atIndex:(UInt32)index;
- (void)reset;

@end

