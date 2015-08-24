//
//  SekerePlayground.m
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

    AKSekereInstrument *sekere = [[AKSekereInstrument alloc] initWithNumber:1];
    [AKOrchestra addInstrument:sekere];

    AKAmplifier *amp = [[AKAmplifier alloc] initWithInput:sekere.output];
    amp.instrumentNumber = 2;
    [AKOrchestra addInstrument:amp];
    [amp start];

    AKSekereNote *note = [[AKSekereNote alloc] init];
    [self addButtonWithTitle:@"Play Once" block:^{ [sekere playNote:note]; }];

    [self addSliderForProperty:sekere.amplitude title:@"Volume"];

    AKPhrase *phrase = [[AKPhrase alloc] init];
    [phrase addNote:note];

    [self makeSection:@"Repeat Frequency"];
    [self addRepeatSliderForInstrument:sekere
                                phrase:phrase
                      minimumFrequency:0.0f
                      maximumFrequency:25.0f];

    [self addButtonWithTitle:@"Stop Loop" block:^{ [sekere stopPhrase]; }];

    [self makeSection:@"Parameters"];
    [self addSliderForProperty:note.count         title:@"Count"];
    [self addSliderForProperty:note.dampingFactor title:@"Damping Factor"];
    [self addSliderForProperty:note.amplitude     title:@"Amplitude"];

    [self addAudioOutputRollingWaveformPlot];
    [self addAudioOutputPlot];
    [self addAudioOutputFFTPlot];
}

@end
