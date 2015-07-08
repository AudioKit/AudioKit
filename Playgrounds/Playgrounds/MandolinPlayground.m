//
//  MandolinPlayground.m
//  AudioKit
//
//  Created by Nick Arner on 3/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@implementation Playground

- (void)run
{
    [super run];

    AKMandolinInstrument *mandolin = [[AKMandolinInstrument alloc] initWithNumber:1];
    [AKOrchestra addInstrument:mandolin];

    AKAmplifier *amp = [[AKAmplifier alloc] initWithInput:mandolin.output];
    amp.instrumentNumber = 2;
    [AKOrchestra addInstrument:amp];
    [amp start];

    AKMandolinNote *note = [[AKMandolinNote alloc] init];

    [self addButtonWithTitle:@"Play Once" block:^{ [mandolin playNote:note]; }];

    [self addSliderForProperty:mandolin.amplitude            title:@"Amplitude"];
    [self addSliderForProperty:mandolin.bodySize             title:@"Body Size"];
    [self addSliderForProperty:mandolin.pairedStringDetuning title:@"Detuning"];

    AKPhrase *phrase = [[AKPhrase alloc] init];
    [phrase addNote:note];

    [self makeSection:@"Repeat Frequency"];
    [self addRepeatSliderForInstrument:mandolin
                                phrase:phrase
                      minimumFrequency:0.0f
                      maximumFrequency:25.0f];

    [self addButtonWithTitle:@"Stop Loop" block:^{ [mandolin stopPhrase]; }];

    [self makeSection:@"Parameters"];

    [self addSliderForProperty:note.frequency     title:@"Frequency"];
    [self addSliderForProperty:note.pluckPosition title:@"Pluck Position"];
    [self addSliderForProperty:note.amplitude     title:@"Amplitude"];

    [self addAudioOutputRollingWaveformPlot];
    [self addAudioOutputPlot];
    [self addAudioOutputFFTPlot];
}

@end
