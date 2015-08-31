//
//  AKReverbPedal.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

/// A reverb processor
@interface AKReverbPedal : AKInstrument

@property (nonatomic) AKInstrumentProperty *feedback;
@property (nonatomic) AKInstrumentProperty *cutoffFrequency;
@property (nonatomic) AKInstrumentProperty *mix;

// Audio outlet for global effects processing
@property (readonly) AKStereoAudio *output;

- (instancetype)initWithInput:(AKAudio *)input;
- (instancetype)initWithStereoInput:(AKStereoAudio *)input;

// Some presets
- (void)setPresetLargeHall;
- (void)setPresetSmallHall;
- (void)setPresetMuffledCan;

@end
