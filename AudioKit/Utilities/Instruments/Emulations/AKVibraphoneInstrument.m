//
//  Vibraphone.m
//  AudioKit
//
//  Created by Nicholas Arner on 3/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKVibraphoneInstrument.h"

@implementation AKVibraphoneInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Note Properties
        AKVibraphoneNote *note = [[AKVibraphoneNote alloc] init];

        // Instrument Properties
        _amplitude = [self createPropertyWithValue:0.5 minimum:0.0 maximum:1.0];

        // Instrument Definition
        AKVibes *vibes = [AKVibes vibes];
        vibes.frequency      = note.frequency;
        vibes.amplitude      = note.amplitude;
        vibes.stickHardness  = note.stickHardness;
        vibes.strikePosition = note.strikePosition;

        _output = [AKAudio globalParameter];
        [self assignOutput:_output to:[vibes scaledBy:_amplitude]];
    }
    return self;
}
@end

// -----------------------------------------------------------------------------
#  pragma mark - Vibraphone Note
// -----------------------------------------------------------------------------


@implementation AKVibraphoneNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _frequency = [self createPropertyWithValue:440 minimum:100 maximum:1000];
        _frequency.isContinuous = NO;
        _amplitude = [self createPropertyWithValue:0.5 minimum:0 maximum:1];
        _amplitude.isContinuous = NO;
        _stickHardness = [self createPropertyWithValue:0.5 minimum:0 maximum:1];
        _stickHardness.isContinuous = NO;
        _strikePosition = [self createPropertyWithValue:0.2 minimum:0 maximum:1];
        _strikePosition.isContinuous = NO;

        // Optionally set a default note duration
        self.duration.value = 1.0;
    }
    return self;
}

@end
