//
//  DelayPedalMicrophonePlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/24/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@implementation Playground {
    AKMicrophone *mic;
    AKDelayPedal *delay;
    AKAmplifier *amp;
}

- (void) setup
{
    [super setup];
    mic = [[AKMicrophone alloc] init];
    [AKOrchestra addInstrument:mic];
    [mic start];

    delay = [[AKDelayPedal alloc] initWithInput:mic.output];
    [AKOrchestra addInstrument:delay];
    [delay start];

    amp = [[AKAmplifier alloc] initWithInput:delay.output];
    [AKOrchestra addInstrument:amp];
    [amp start];
}

- (void)run
{
    [super run];

    [self addSliderForProperty:delay.time title:@"Delay Time"];
    [self addSliderForProperty:delay.feedback title:@"Feedback"];
    [self addSliderForProperty:delay.mix title:@"Mix"];

    [self makeSection:@"Playground Presets"];

    [self addButtonWithTitle:@"SSSAAAFFFEEETTT" block:^{
        delay.time.value = 0.2;
        delay.feedback.value = 0.4;
        delay.mix.value = 0.5;
    }];

    [self makeSection:@"Delay Pedal Presets"];

    [self addButtonWithTitle:@"Small Chamber" block:^{[delay setPresetSmallChamber];}];
    [self addButtonWithTitle:@"Robot Voice" block:^{[delay setPresetRobotVoice];}];
    [self addButtonWithTitle:@"Daleks" block:^{[delay setPresetDaleks];}];

}

@end
