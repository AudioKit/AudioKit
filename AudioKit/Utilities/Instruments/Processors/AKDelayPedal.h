//
//  AKDelayPedal.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/25/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKFoundation.h"

/// AudioKit Delay Pedal instrument
@interface AKDelayPedal : AKInstrument

/// Amount of feedback (0-1)
@property AKInstrumentProperty *feedback;

/// Delay time in seconds
@property AKInstrumentProperty *time;

/// Source and delay mix (0-1)
@property AKInstrumentProperty *mix;

/// Audio outlet for global effects processing
@property (readonly) AKAudio *output;

/// Initialize the delay line with an input
/// @param input The input source audio signal
- (instancetype)initWithInput:(AKAudio *)input;

# pragma mark Presets

/// A small chamber preset
- (void)setPresetSmallChamber;

/// A robotic voice preset
- (void)setPresetRobotVoice;

/// A menacing robotic voice preset
- (void)setPresetDaleks;

@end
