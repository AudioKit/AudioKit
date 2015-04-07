//
//  OscillatorPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/11/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@implementation Playground

- (void)run
{
    [super run];

    AKInstrument *instrument = [[AKInstrument alloc] initWithNumber:1];

    AKOscillator *oscillator = [AKOscillator oscillator];
    AKOscillator *vibrato = [AKOscillator oscillator];
    vibrato.frequency = akp(1);
    vibrato.amplitude = akp(4);
    AKConstant *baseFrequency = akp(440);
    oscillator.frequency =  [baseFrequency plus:vibrato];
    oscillator.amplitude = akp(0.5);
    [instrument setAudioOutput:oscillator];

    [AKOrchestra addInstrument:instrument];

    [instrument restart];

    [self addButtonWithTitle:@"Play" block:^{ [instrument play]; }];
    [self addButtonWithTitle:@"Stop" block:^{ [instrument stop]; }];

    [self addAudioOutputRollingWaveformPlot];
    [self addAudioOutputPlot];
    [self addAudioOutputFFTPlot];
}

@end
