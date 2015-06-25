//
//  DelayPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/24/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@interface Delay : AKInstrument
@property AKInstrumentProperty *feedback;
@property AKInstrumentProperty *time;
@property AKInstrumentProperty *mix;
@end

@implementation Delay

- (instancetype)initWithInput:(AKAudio *)input
{
    self = [super initWithNumber:2];
    if (self) {
        _time = [self createPropertyWithValue:0.2 minimum:0 maximum:3];
        _feedback = [self createPropertyWithValue:0.4 minimum:0 maximum:1.0];
        _mix = [self createPropertyWithValue:0.5 minimum:0.5 maximum:1.0];

        AKVariableDelay *delay = [[AKVariableDelay alloc] initWithInput:input
                                                              delayTime:_time
                                                       maximumDelayTime:akp(_time.maximum)];
        AKMix *mix = [[AKMix alloc] initWithInput1:input input2:delay balance:_mix];

        [self setAudioOutput:mix];
        [self resetParameter:input];
        AKAssignment *feedback = [[AKAssignment alloc] initWithOutput:input input:[delay scaledBy:_feedback]];
        [self connect:feedback];
    }
    return self;
}

@end

@implementation Playground

- (void) setup
{
    [super setup];
}

- (void)run
{
    [super run];

    AKMicrophone *mic = [[AKMicrophone alloc] initWithNumber:1];
    [AKOrchestra addInstrument:mic];
    [mic restart];

    Delay *delay = [[Delay alloc] initWithInput:mic.auxilliaryOutput];
    [AKOrchestra addInstrument:delay];
    [delay restart];

    [self addSliderForProperty:delay.time title:@"Delay Time"];
    [self addSliderForProperty:delay.feedback title:@"Feedback"];

    [self makeSection:@"Presets"];

    [self addButtonWithTitle:@"SSSAAAFFFEEETTT" block:^{
        delay.time.value = 0.2;
        delay.feedback.value = 0.4;
        delay.mix.value = 0.5;
    }];

    [self addButtonWithTitle:@"Small Chamber" block:^{
        delay.time.value = 0.1;
        delay.feedback.value = 0.5;
        delay.mix.value = 0.5;
    }];

    [self addButtonWithTitle:@"Robot Voice" block:^{
        delay.time.value = 0.01;
        delay.feedback.value = 0.9;
        delay.mix.value = 1.0;
    }];

    [self addButtonWithTitle:@"Daleks" block:^{
        delay.time.value = 0.001;
        delay.feedback.value = 0.95;
        delay.mix.value = 1.0;
    }];

}

@end
