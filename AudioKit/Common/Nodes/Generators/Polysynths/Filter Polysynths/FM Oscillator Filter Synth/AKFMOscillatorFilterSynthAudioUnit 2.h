//
//  AKFMOscillatorFilterSynthAudioUnit.h
//  AudioKit
//
//  Created by Colin Hallett, revision history on Github.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#pragma once

#import "AKFilterSynthAudioUnit.h"

@interface AKFMOscillatorFilterSynthAudioUnit : AKFilterSynthAudioUnit

@property (nonatomic) float carrierMultiplier;
@property (nonatomic) float modulatingMultiplier;
@property (nonatomic) float modulationIndex;

- (void)setupWaveform:(int)size;
- (void)setWaveformValue:(float)value atIndex:(UInt32)index;

@end
