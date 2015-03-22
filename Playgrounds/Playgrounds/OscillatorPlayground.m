//
//  SynthesisPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/11/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@implementation Playground

- (void) setup
{
    [super setup];
}

- (void)run
{
    [super run];

    [self addAudioOutputPlot];
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

    AKPlaygroundButton(@"Play", [instrument play];);
    AKPlaygroundButton(@"Stop", [instrument stop];);


}

@end
