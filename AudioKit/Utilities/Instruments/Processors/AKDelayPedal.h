//
//  AKDelayPedal.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/25/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKFoundation.h"

@interface AKDelayPedal : AKInstrument
@property AKInstrumentProperty *feedback;
@property AKInstrumentProperty *time;
@property AKInstrumentProperty *mix;

- (instancetype)initWithInput:(AKAudio *)input;

# pragma mark Presets

- (void)setPresetSmallChamber;
- (void)setPresetRobotVoice;
- (void)setPresetDaleks;

@end
