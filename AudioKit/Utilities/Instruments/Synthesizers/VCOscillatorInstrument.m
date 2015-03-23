//
//  VCOscillatorInstrument.m
//  AudioKitPlayground
//
//  Created by Aurelius Prochazka on 3/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "VCOscillatorInstrument.h"

@implementation VCOscillatorInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        _amplitude = [[AKInstrumentProperty alloc] initWithValue:0.5 minimum:0 maximum:1];
        VCOscillatorNote *note = [[VCOscillatorNote alloc] init];
        AKVCOscillator *vco = [AKVCOscillator oscillator];
        vco.amplitude = _amplitude;
        vco.frequency = note.frequency;
        vco.waveformType = note.waveformType;
        [self setAudioOutput:vco];
    }
    return self;
}

@end


@implementation VCOscillatorNote

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