//
//  CombFilterPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/17/15. (But it feels like Halloween!)
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@interface CombFilter : AKInstrument
@property AKInstrumentProperty *reverbDuration;
@property AKInstrumentProperty *mix;
@end

@implementation CombFilter

- (instancetype)initWithInput:(AKAudio *)input
{
    self = [super initWithNumber:2];
    if (self) {
        _reverbDuration = [self createPropertyWithValue:1.0 minimum:0.0 maximum:5.0];
        _mix = [self createPropertyWithValue:0 minimum:0 maximum:1];
        AKCombFilter *comb = [[AKCombFilter alloc] initWithInput:input];
        comb.reverbDuration = _reverbDuration;
        comb.loopDuration.value = 0.1;

        AKMix *mix = [[AKMix alloc] initWithInput1:comb input2:input balance:_mix];
        [self setAudioOutput:mix];
        [self resetParameter:input];
    }
    return self;
}

@end

@implementation Playground

- (void)run
{
    [super run];

    [[AKManager sharedManager] setIsLogging:YES];

    AKMicrophone *mic = [[AKMicrophone alloc] initWithNumber:1];
    [AKOrchestra addInstrument:mic];
    [mic restart];

    CombFilter *combFilter = [[CombFilter alloc] initWithInput:mic.output];
    [AKOrchestra addInstrument:combFilter];
    [combFilter restart];

    [self addSliderForProperty:combFilter.reverbDuration title:@"Reverb Duration"];
    [self addSliderForProperty:combFilter.mix title:@"Mix"];

    [self addAudioInputPlot];
    [self addAudioOutputPlot];

}

@end
