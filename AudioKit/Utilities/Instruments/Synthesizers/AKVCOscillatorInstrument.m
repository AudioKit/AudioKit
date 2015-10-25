//
//  VCOscillatorInstrument.m
//  AudioKitPlayground
//
//  Created by Aurelius Prochazka on 3/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKVCOscillatorInstrument.h"

@implementation AKVCOscillatorInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        _amplitude = [[AKInstrumentProperty alloc] initWithValue:0.5 minimum:0 maximum:1];
        AKVCOscillatorNote *note = [[AKVCOscillatorNote alloc] init];
        AKVCOscillator *vco = [AKVCOscillator oscillator];
        vco.amplitude = _amplitude;
        vco.frequency = note.frequency;
        vco.waveformType = note.waveformType;
        
        _output = [AKAudio globalParameter];
        [self assignOutput:_output to:[vco scaledBy:_amplitude]];
    }
    return self;
}

@end


@implementation AKVCOscillatorNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _waveformType = [self createPropertyWithValue:0 minimum:0 maximum:100];
        _frequency = [self createPropertyWithValue:646.0 minimum:0 maximum:2000];
    }
    return self;
}

@end