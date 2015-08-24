//
//  Mandolin.m
//  AudioKit
//
//  Created by Nicholas Arner on 3/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKMandolinInstrument.h"

@implementation AKMandolinInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Note Properties
        AKMandolinNote *note = [[AKMandolinNote alloc] init];

        // Instrument Properties
        _bodySize = [self createPropertyWithValue:0.5 minimum:0.0 maximum:1.0];
        _pairedStringDetuning = [self createPropertyWithValue:1.0 minimum:0.9 maximum:1.0];
        _amplitude = [self createPropertyWithValue:0.5 minimum:0.0 maximum:1.0];

        // Instrument Definition
        AKMandolin *mandolin = [AKMandolin mandolin];
        mandolin.frequency            = note.frequency;
        mandolin.bodySize             = _bodySize;
        mandolin.pluckPosition        = note.pluckPosition;
        mandolin.pairedStringDetuning = _pairedStringDetuning;
        mandolin.amplitude            = note.amplitude;

        _output = [AKAudio globalParameter];
        [self assignOutput:_output to:[mandolin scaledBy:_amplitude]];
    }
    return self;
}
@end

// -----------------------------------------------------------------------------
#  pragma mark - Mandolin Note
// -----------------------------------------------------------------------------


@implementation AKMandolinNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _frequency = [self createPropertyWithValue:440 minimum:100 maximum:1000];
        _frequency.isContinuous = NO;
        _pluckPosition = [self createPropertyWithValue:0.4 minimum:0.0 maximum:1.0];
        _pluckPosition.isContinuous = NO;
        _amplitude = [self createPropertyWithValue:1 minimum:0 maximum:1];
        _amplitude.isContinuous = NO;

        // Optionally set a default note duration
        self.duration.value = 1.0;
    }
    return self;
}


@end
