//
//  Stick.m
//  AudioKit
//
//  Created by Nicholas Arner on 3/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKStickInstrument.h"

@implementation AKStickInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Note Properties
        AKStickNote *note = [[AKStickNote alloc] init];

        // Instrument Properties
        _amplitude = [self createPropertyWithValue:1.0 minimum:0.0 maximum:1.0];

        // Instrument Definition
        AKStick *stick = [AKStick stick];
        stick.intensity     = note.intensity;
        stick.dampingFactor = note.dampingFactor;
        stick.amplitude     = note.amplitude;

        _output = [AKAudio globalParameter];
        [self assignOutput:_output to:[stick scaledBy:_amplitude]];
    }
    return self;
}
@end

// -----------------------------------------------------------------------------
#  pragma mark - Stick Note
// -----------------------------------------------------------------------------


@implementation AKStickNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _intensity = [self createPropertyWithValue:30 minimum:10 maximum:40];
        _intensity.isContinuous = NO;
        _dampingFactor = [self createPropertyWithValue:0.3 minimum:0 maximum:1];
        _dampingFactor.isContinuous = NO;
        _amplitude = [self createPropertyWithValue:1 minimum:0 maximum:1];
        _amplitude.isContinuous = NO;

        // Optionally set a default note duration
        self.duration.value = 1.0;
    }
    return self;
}



@end
