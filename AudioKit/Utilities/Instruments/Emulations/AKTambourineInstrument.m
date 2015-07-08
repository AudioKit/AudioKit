//
//  Tambourine.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTambourineInstrument.h"

@implementation AKTambourineInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        _amplitude = [self createPropertyWithValue:0.5 minimum:0.0 maximum:1.0];
        
        AKTambourineNote *note = [[AKTambourineNote alloc] init];
        AKTambourine *tambourine = [AKTambourine tambourine];
        tambourine.dampingFactor           = note.dampingFactor;
        tambourine.intensity               = note.intensity;
        tambourine.mainResonantFrequency   = note.mainResonantFrequency;
        tambourine.firstResonantFrequency  = note.firstResonantFrequency;
        tambourine.secondResonantFrequency = note.secondResonantFrequency;

        _output = [AKAudio globalParameter];
        [self assignOutput:_output to:[tambourine scaledBy:_amplitude]];
    }
    return self;
}
@end

// -----------------------------------------------------------------------------
#  pragma mark - Tambourine Note
// -----------------------------------------------------------------------------

@implementation AKTambourineNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _intensity     = [self createPropertyWithValue:20.0 minimum:0 maximum:1000];
        _dampingFactor = [self createPropertyWithValue:0.1 minimum:0 maximum:1];
        _dampingFactor.isContinuous = NO;
        _mainResonantFrequency = [self createPropertyWithValue:2300 minimum:0 maximum:10000];
        _mainResonantFrequency.isContinuous = NO;
        _firstResonantFrequency = [self createPropertyWithValue:5600 minimum:0 maximum:10000];
        _firstResonantFrequency.isContinuous = NO;
        _secondResonantFrequency = [self createPropertyWithValue:8100 minimum:0 maximum:10000];
        _secondResonantFrequency.isContinuous = NO;
        self.duration.value = 1.0;
    }
    return self;
}

- (instancetype)initWithIntensity:(float)intensity dampingFactor:(float)dampingFactor
{
    self = [self init];
    if (self) {
        _intensity.value = intensity;
        _dampingFactor.value = dampingFactor;
    }
    return self;
}

@end
