//
//  AKPhaseDistortionOscillatorBankAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AKBankAudioUnit.h"

@interface AKPhaseDistortionOscillatorBankAudioUnit : AKBankAudioUnit

@property (nonatomic) float phaseDistortion;

- (void)setupWaveform:(int)size;
- (void)setWaveformValue:(float)value atIndex:(UInt32)index;

@end

