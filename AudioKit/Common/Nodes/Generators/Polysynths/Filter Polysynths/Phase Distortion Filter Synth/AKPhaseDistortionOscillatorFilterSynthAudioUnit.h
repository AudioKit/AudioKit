//
//  AKPhaseDistortionOscillatorFilterSynthAudioUnit.h
//  AudioKit
//
//  Created by Colin Hallett, revision history on Github.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#pragma once

#import "AKFilterSynthAudioUnit.h"

@interface AKPhaseDistortionOscillatorFilterSynthAudioUnit : AKFilterSynthAudioUnit

@property (nonatomic) float phaseDistortion;

- (void)setupWaveform:(int)size;
- (void)setWaveformValue:(float)value atIndex:(UInt32)index;

@end

