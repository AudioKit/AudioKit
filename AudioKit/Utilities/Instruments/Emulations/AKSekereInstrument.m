//
//  Sekere.m
//  AudioKitPlayground
//
//  Created by Nicholas Arner on 3/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKSekereInstrument.h"

@implementation AKSekereInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Note Properties
        AKSekereNote *note = [[AKSekereNote alloc] init];

        // Instrument Properties
        _amplitude = [self createPropertyWithValue:1.0 minimum:0.0 maximum:1.0];

        // Instrument Definition
        AKSekere *sekere = [AKSekere sekere];
        sekere.count         = note.count;
        sekere.dampingFactor = note.dampingFactor;
        sekere.amplitude     = note.amplitude;

        _output = [AKAudio globalParameter];
        [self assignOutput:_output to:[sekere scaledBy:_amplitude]];
    }
    return self;
}
@end

// -----------------------------------------------------------------------------
#  pragma mark - Sekere Note
// -----------------------------------------------------------------------------


@implementation AKSekereNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _count = [self createPropertyWithValue:64 minimum:32 maximum:200];
        _count.isContinuous = NO;
        _dampingFactor = [self createPropertyWithValue:0.1 minimum:0 maximum:1];
        _dampingFactor.isContinuous = NO;
        _amplitude = [self createPropertyWithValue:1 minimum:0 maximum:1];
        _amplitude.isContinuous = NO;


        // Optionally set a default note duration
        self.duration.value = 1.0;
    }
    return self;
}



@end
