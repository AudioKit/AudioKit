//
//  ReverbPedalMicrophonePlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/24/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@implementation Playground {
    AKMicrophone *mic;
    AKReverbPedal *reverb;
    AKStereoAmplifier *amp;
}

- (void) setup
{
    [super setup];
    mic = [[AKMicrophone alloc] init];
    [AKOrchestra addInstrument:mic];
    [mic start];

    reverb = [[AKReverbPedal alloc] initWithInput:mic.output];
    [AKOrchestra addInstrument:reverb];
    [reverb start];

    amp = [[AKStereoAmplifier alloc] initWithStereoInput:reverb.output];
    [AKOrchestra addInstrument:amp];
    [amp start];
}

- (void)run
{
    [super run];

    [self addSliderForProperty:reverb.feedback title:@"Feedback"];
    [self addSliderForProperty:reverb.mix title:@"Mix"];

    [self addButtonWithTitle:@"Large Hall" block:^{
        [reverb setPresetLargeHall];
    }];

    [self addButtonWithTitle:@"Small Hall" block:^{
        [reverb setPresetSmallHall];
    }];

    [self addButtonWithTitle:@"Muffled Can" block:^{
        [reverb setPresetMuffledCan];
    }];

    [self addAudioOutputPlot];
    [self addAudioOutputRollingWaveformPlot];
}

@end
