// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import "AKFilterSynthAudioUnit.h"

@interface AKPhaseDistortionOscillatorFilterSynthAudioUnit : AKFilterSynthAudioUnit

@property (nonatomic) float phaseDistortion;

- (void)setupWaveform:(int)size;
- (void)setWaveformValue:(float)value atIndex:(UInt32)index;

@end

