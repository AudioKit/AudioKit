//
//  FMOscillatorInstrument.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFMOscillatorInstrument.h"

@implementation AKFMOscillatorInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Note Properties
        AKFMOscillatorNote *note = [[AKFMOscillatorNote alloc] init];

        // Instrument Properties
        _amplitude = [self createPropertyWithValue:0.5 minimum:0.0 maximum:1.0];

        // Instrument Definition
        AKFMOscillator *oscillator = [AKFMOscillator oscillator];
        oscillator.baseFrequency = note.frequency;
        oscillator.amplitude = note.amplitude;

        [self setAudioOutput:[oscillator scaledBy:_amplitude]];
    }
    return self;
}
@end

// -----------------------------------------------------------------------------
#  pragma mark - FMOscillatorInstrument Note
// -----------------------------------------------------------------------------


@implementation AKFMOscillatorNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _frequency = [self createPropertyWithValue:440 minimum:100 maximum:20000];
        _amplitude = [self createPropertyWithValue:1 minimum:0 maximum:1];
    }
    return self;
}

- (instancetype)initWithFrequency:(float)frequency amplitude:(float)amplitude;
{
    self = [self init];
    if (self) {
        _frequency.value = frequency;
        _amplitude.value = amplitude;
    }
    return self;
}

@end
