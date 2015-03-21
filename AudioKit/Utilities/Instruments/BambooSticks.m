//
//  BambooSticks.m
//  AudioKitPlayground
//
//  Created by Nicholas Arner on 3/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "BambooSticks.h"

@implementation BambooSticks

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Note Properties
        BambooSticksNote *note = [[BambooSticksNote alloc] init];

        // Instrument Properties
        _amplitude = [self createPropertyWithValue:1.0 minimum:0.0 maximum:1.0];

        // Instrument Definition
        AKBambooSticks *bambooSticks = [AKBambooSticks sticks];
        bambooSticks.count = note.count;
        bambooSticks.mainResonantFrequency = note.mainResonantFrequency;
        bambooSticks.firstResonantFrequency = note.firstResonantFrequency;
        bambooSticks.secondResonantFrequency = note.secondResonantFrequency;
        bambooSticks.amplitude = note.amplitude;

        [self setAudioOutput:[bambooSticks scaledBy:_amplitude]];

        // Output to global effects processing (choose mono or stereo accordingly)
        _auxilliaryOutput = [AKAudio globalParameter];
        [self assignOutput:_auxilliaryOutput to:bambooSticks];
    }
    return self;
}
@end

// -----------------------------------------------------------------------------
#  pragma mark - BambooSticks Note
// -----------------------------------------------------------------------------


@implementation BambooSticksNote

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
