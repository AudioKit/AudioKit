//
//  OscillatorInstrument.m
//  TableDemo
//
//  Created by Aurelius Prochazka on 4/17/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "OscillatorInstrument.h"

@implementation OscillatorInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Instrument Properties
        _amplitude = [self createPropertyWithValue:0.75 minimum:0.0 maximum:1.0];
        _frequency = [self createPropertyWithValue:861 minimum:0 maximum:4000];
        
        // Instrument Definition
        _oscillator = [AKOscillator oscillator];
        _oscillator.frequency = _frequency;
        
        [self setAudioOutput:[_oscillator scaledBy:_amplitude]];
    }
    return self;
}
@end
