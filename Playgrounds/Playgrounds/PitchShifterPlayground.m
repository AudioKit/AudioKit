//
//  PitchShifterPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/24/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@implementation Playground {
    AKPitchShifterPedal *pitchShift;
}

- (void) setup
{
    [super setup];

    AKMicrophone *mic = [[AKMicrophone alloc] initWithNumber:1];
    [AKOrchestra addInstrument:mic];
    [mic start];

    pitchShift = [[AKPitchShifterPedal alloc] initWithInput:mic.output];
    [AKOrchestra addInstrument:pitchShift];
    [pitchShift start];

    AKAmplifier *amp = [[AKAmplifier alloc] initWithInput:pitchShift.output];
    [AKOrchestra addInstrument:amp];
    [amp start];

    [self addSliderForProperty:pitchShift.frequencyShift title:@"Frequency Shift"];
    [self addSliderForProperty:pitchShift.feedback title:@"Feedback"];
    [self addSliderForProperty:pitchShift.mix title:@"Mix"];
}

- (void)run
{
    [super run];

    [self makeSection:@"Playground Presets"];

    pitchShift.frequencyShift.value = 1.5;
    pitchShift.feedback.value = 0;
    pitchShift.mix.value = 0.5;

    [self addButtonWithTitle:@"Witness Protection" block:^{
        [pitchShift setPresetWitnessProtection];
    }];

    [self addButtonWithTitle:@"Arcade Fire" block:^{
        [pitchShift setPresetArcadeFire];
    }];

    [self addButtonWithTitle:@"Hard Braker" block:^{
        [pitchShift setPresetHardBraker];
    }];

    [self addButtonWithTitle:@"Perfect Fifth Up" block:^{
        [pitchShift setPresetPerfectFifthUp];
    }];

    [self addButtonWithTitle:@"Perfect Fourth Up" block:^{
        [pitchShift setPresetPerfectFourthUp];
    }];

    [self addButtonWithTitle:@"Perfect Fourth Down" block:^{
        [pitchShift setPresetPerfectFourthDown];
    }];

    [self addButtonWithTitle:@"Perfect Fifth Down" block:^{
        [pitchShift setPresetPerfectFifthDown];
    }];


}

@end
