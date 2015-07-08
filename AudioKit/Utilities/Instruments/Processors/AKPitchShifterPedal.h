//
//  AKPitchShifterPedal.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/27/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKFoundation.h"

@interface AKPitchShifterPedal : AKInstrument
@property AKInstrumentProperty *frequencyShift;
@property AKInstrumentProperty *feedback;
@property AKInstrumentProperty *mix;

// Audio outlet for global effects processing
@property (readonly) AKAudio *output;

- (instancetype)initWithInput:(AKAudio *)input;

- (void)setPresetWitnessProtection;
- (void)setPresetArcadeFire;
- (void)setPresetHardBraker;
- (void)setPresetPerfectFifthUp;
- (void)setPresetPerfectFourthUp;
- (void)setPresetPerfectFourthDown;
- (void)setPresetPerfectFifthDown;

@end
