//
//  HelloWorldPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/26/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@implementation Playground

// This is the Hello World playground developed on http://audiokit.io/playgrounds/
// Go to the web site for a screencast of this being created

- (void)run
{
    [super run];

    AKInstrument *instrument = [AKInstrument instrumentWithNumber:1];

    AKOscillator *oscillator = [AKOscillator oscillator];
    oscillator.frequency = akp(110);
    oscillator.amplitude = akp(0.5);
    oscillator.waveform = [AKTable standardTriangleWave];

    AKVibrato *vibrato = [AKVibrato vibrato];
    vibrato.averageAmplitude = akp(100);
    vibrato.averageFrequency = akp(1);
    vibrato.shape = [AKTable standardReverseSawtoothWave];
    oscillator.frequency = [akp(220) plus:vibrato];

    [instrument setAudioOutput:oscillator];
    [AKOrchestra addInstrument:instrument];

    [instrument restart];
    [self addButtonWithTitle:@"stop" block:^{
        [instrument stop];
    }];

    [self addButtonWithTitle:@"play" block:^{
        [instrument restart];
    }];
    [self addAudioOutputPlot];
}

@end
