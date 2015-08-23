//
//  AKPitchShifterPedal.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/27/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKFoundation.h"

/// AudioKit Pitch Shifter Pedal instrument
@interface AKPitchShifterPedal : AKInstrument

/// How much to shift the frequency (1=None, <1 lower, >1 higher)
@property AKInstrumentProperty *frequencyShift;

/// Amount of feedback (0-1)
@property AKInstrumentProperty *feedback;

/// Source and delay mix (0-1)
@property AKInstrumentProperty *mix;

// Audio outlet for global effects processing
@property (readonly) AKAudio *output;

/// Initialize the pitch shifter with an input
/// @param input The input source audio signal
- (instancetype)initWithInput:(AKAudio *)input;

/// A lowered voice preset
- (void)setPresetWitnessProtection;

/// An old school arcade fire button sound preset
- (void)setPresetArcadeFire;

/// A progressive lowering of a pitch preset
- (void)setPresetHardBraker;

/// A preset for a perfect fifth higher
- (void)setPresetPerfectFifthUp;

/// A preset for a perfect fourth higher
- (void)setPresetPerfectFourthUp;

/// A preset for a perfect fourth lower
- (void)setPresetPerfectFourthDown;

/// A preset for a perfect fifth lower
- (void)setPresetPerfectFifthDown;

@end
