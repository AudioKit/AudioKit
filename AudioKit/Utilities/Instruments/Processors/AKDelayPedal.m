//
//  AKDelayPedal.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/25/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKDelayPedal.h"

@implementation AKDelayPedal

- (instancetype)initWithInput:(AKAudio *)input
{
    self = [super init];
    if (self) {
        _time     = [self createPropertyWithValue:0.2 minimum:0.0 maximum:3.0];
        _feedback = [self createPropertyWithValue:0.4 minimum:0.0 maximum:1.0];
        _mix      = [self createPropertyWithValue:0.5 minimum:0.5 maximum:1.0];

        AKVariableDelay *delay = [[AKVariableDelay alloc] initWithInput:input
                                                              delayTime:_time
                                                       maximumDelayTime:akp(_time.maximum)];
        AKMix *mix = [[AKMix alloc] initWithInput1:input input2:delay balance:_mix];

        _output = [AKAudio globalParameter];
        [self assignOutput:_output to:mix];

        AKAssignment *feedback = [[AKAssignment alloc] initWithOutput:input input:[delay scaledBy:_feedback]];
        [self connect:feedback];
    }
    return self;
}

- (void)setPresetSmallChamber
{
    _time.value = 0.1;
    _feedback.value = 0.5;
    _mix.value = 0.5;
}

- (void)setPresetRobotVoice
{
    _time.value = 0.01;
    _feedback.value = 0.9;
    _mix.value = 1.0;
}

- (void)setPresetDaleks
{
    _time.value = 0.001;
    _feedback.value = 0.95;
    _mix.value = 1.0;
}

@end
