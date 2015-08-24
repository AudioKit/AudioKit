//
//  BambooSticksPlayground.m
//  AudioKit
//
//  Created by Nick Arner on 3/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@implementation Playground

- (void)run
{
    [super run];

    AKBambooSticksInstrument *bambooSticks = [[AKBambooSticksInstrument alloc] initWithNumber:1];
    [AKOrchestra addInstrument:bambooSticks];

    AKAmplifier *amp = [[AKAmplifier alloc] initWithInput:bambooSticks.output];
    amp.instrumentNumber = 2;
    [AKOrchestra addInstrument:amp];
    [amp start];

    AKBambooSticksNote *note = [[AKBambooSticksNote alloc] init];
    [self addButtonWithTitle:@"Play Once" block:^{ [bambooSticks playNote:note]; }];

    [self addSliderForProperty:bambooSticks.amplitude title:@"Volume"];

    AKPhrase *phrase = [[AKPhrase alloc] init];
    [phrase addNote:note];

    [self makeSection:@"Repeat Frequency"];
    [self addRepeatSliderForInstrument:bambooSticks
                                phrase:phrase
                      minimumFrequency:0.0f
                      maximumFrequency:25.0f];

    [self addButtonWithTitle:@"Stop Loop" block:^{ [bambooSticks stopPhrase]; }];

    [self makeSection:@"Parameters"];
    [self addSliderForProperty:note.count                   title:@"Count"];
    [self addSliderForProperty:note.mainResonantFrequency   title:@"Main Resonant Freq."];
    [self addSliderForProperty:note.firstResonantFrequency  title:@"1st Resonant Freq."];
    [self addSliderForProperty:note.secondResonantFrequency title:@"2nd Resonant Freq."];
    [self addSliderForProperty:note.amplitude               title:@"Amplitude"];

    [self addAudioOutputRollingWaveformPlot];
    [self addAudioOutputPlot];
    [self addAudioOutputFFTPlot];
}

@end
