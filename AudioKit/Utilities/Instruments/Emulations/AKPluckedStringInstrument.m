//
//  PluckedString.m
//  AudioKit
//
//  Created by Nicholas Arner on 3/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKPluckedStringInstrument.h"

@implementation AKPluckedStringInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Note Properties
        AKPluckedStringNote *note = [[AKPluckedStringNote alloc] init];

        // Instrument Properties
        _amplitude = [self createPropertyWithValue:1.0 minimum:0.0 maximum:1.0];

        // Instrument Definition
        AKPluckedString *pluckedString = [AKPluckedString pluck];
        pluckedString.frequency             = note.frequency;
        pluckedString.pluckPosition         = note.pluckPosition;
        pluckedString.samplePosition        = note.samplePosition;
        pluckedString.reflectionCoefficient = note.reflectionCoefficient;
        pluckedString.amplitude             = note.amplitude;

        _output = [AKAudio globalParameter];
        [self assignOutput:_output to:[pluckedString scaledBy:_amplitude]];
    }
    return self;
}
@end

// -----------------------------------------------------------------------------
#  pragma mark - PluckedString Note
// -----------------------------------------------------------------------------


@implementation AKPluckedStringNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _frequency = [self createPropertyWithValue:440 minimum:100 maximum:1000];
        _frequency.isContinuous = NO;
        _pluckPosition = [self createPropertyWithValue:0.1 minimum:0.0 maximum:1.0];
        _pluckPosition.isContinuous = NO;
        _samplePosition = [self createPropertyWithValue:0.1 minimum:0.0 maximum:1.0];
        _samplePosition.isContinuous = NO;
        _reflectionCoefficient = [self createPropertyWithValue:0.1 minimum:0.1 maximum:0.9];
        _reflectionCoefficient.isContinuous = NO;
        _amplitude = [self createPropertyWithValue:1 minimum:0 maximum:1];
        _amplitude.isContinuous = NO;


        // Optionally set a default note duration
        self.duration.value = 1.0;
    }
    return self;
}



@end
