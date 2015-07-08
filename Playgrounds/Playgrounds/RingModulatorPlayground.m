//
//  RingModulatorPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@interface RingModulator : AKInstrument

@end

@implementation RingModulator

- (instancetype)initWithInput:(AKAudio *)input
{
    self = [super initWithNumber:2];
    if (self) {
        AKOscillator *oscillator = [AKOscillator oscillator];
        oscillator.waveform = [AKTable standardTriangleWave];
        oscillator.amplitude = akp(0.9);
        AKVibrato   *vibrato = [AKVibrato vibrato];
        vibrato.averageAmplitude = akp(100);
        vibrato.averageFrequency = akp(2);
        vibrato.shape = [AKTable standardTriangleWave];
        oscillator.frequency = [vibrato plus:akp(440)];
        AKRingModulator *ring = [AKRingModulator modulationWithInput:input carrier:oscillator];
        [self setAudioOutput:ring];

        [self resetParameter:input];

    }
    return self;
}

@end

@implementation Playground

- (void)run
{
    [super run];

    AKMicrophone *mic = [[AKMicrophone alloc] initWithNumber:1];
    [AKOrchestra addInstrument:mic];
    RingModulator *ringmod = [[RingModulator alloc] initWithInput:mic.output];
    [AKOrchestra addInstrument:ringmod];
    [ringmod restart];
    [mic restart];
}

@end
