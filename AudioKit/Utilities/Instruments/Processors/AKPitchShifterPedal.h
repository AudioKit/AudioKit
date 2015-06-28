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

- (instancetype)initWithInput:(AKAudio *)input;

- (void)setPresetWitnessProtection;
- (void)setPresetArcadeFire;
- (void)setPresetHardBraker;
- (void)setPresetPerfectFifthUp;
- (void)setPresetPerfectFourthUp;
- (void)setPresetPerfectFourthDown;
- (void)setPresetPerfectFifthDown;

@end
