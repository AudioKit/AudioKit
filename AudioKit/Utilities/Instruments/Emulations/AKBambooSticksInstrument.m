//
//  BambooSticks.m
//  AudioKitPlayground
//
//  Created by Nicholas Arner on 3/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKBambooSticksInstrument.h"

@implementation AKBambooSticksInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Note Properties
        AKBambooSticksNote *note = [[AKBambooSticksNote alloc] init];

        // Instrument Properties
        _amplitude = [self createPropertyWithValue:1.0 minimum:0.0 maximum:1.0];

        // Instrument Definition
        AKBambooSticks *bambooSticks = [AKBambooSticks sticks];
        bambooSticks.count                   = note.count;
        bambooSticks.mainResonantFrequency   = note.mainResonantFrequency;
        bambooSticks.firstResonantFrequency  = note.firstResonantFrequency;
        bambooSticks.secondResonantFrequency = note.secondResonantFrequency;
        bambooSticks.amplitude               = note.amplitude;

        _output = [AKAudio globalParameter];
        [self assignOutput:_output to:[bambooSticks scaledBy:_amplitude]];
    }
    return self;
}
@end

// -----------------------------------------------------------------------------
#  pragma mark - BambooSticks Note
// -----------------------------------------------------------------------------


@implementation AKBambooSticksNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _count = [self createPropertyWithValue:2 minimum:1 maximum:40];
        _count.isContinuous = NO;
        _mainResonantFrequency = [self createPropertyWithValue:2800 minimum:1 maximum:4000];
        _mainResonantFrequency.isContinuous = NO;
        _firstResonantFrequency = [self createPropertyWithValue:2240 minimum:1 maximum:4000];
        _firstResonantFrequency.isContinuous = NO;
        _secondResonantFrequency = [self createPropertyWithValue:3360 minimum:1 maximum:4000];
        _secondResonantFrequency.isContinuous = NO;
        _amplitude = [self createPropertyWithValue:1 minimum:0 maximum:1];
        _amplitude.isContinuous = NO;


        // Optionally set a default note duration
        self.duration.value = 1.0;
    }
    return self;
}



@end
