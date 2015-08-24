//
//  PluckedStringPlayground.m
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

    AKPluckedStringInstrument *pluckedString = [[AKPluckedStringInstrument alloc] initWithNumber:1];
    [AKOrchestra addInstrument:pluckedString];


    AKAmplifier *amp = [[AKAmplifier alloc] initWithInput:pluckedString.output];
    amp.instrumentNumber = 2;
    [AKOrchestra addInstrument:amp];
    [amp start];

    AKPluckedStringNote *note = [[AKPluckedStringNote alloc] init];

    [self addButtonWithTitle:@"Play Once" block:^{ [pluckedString playNote:note]; }];

    [self addSliderForProperty:pluckedString.amplitude title:@"Amplitude"];

    AKPhrase *phrase = [[AKPhrase alloc] init];
    [phrase addNote:note];

    [self makeSection:@"Repeat Frequency"];
    [self addRepeatSliderForInstrument:pluckedString
                                phrase:phrase
                      minimumFrequency:0.0f
                      maximumFrequency:25.0f];

    [self addButtonWithTitle:@"Stop Loop" block:^{ [pluckedString stopPhrase]; }];

    [self makeSection:@"Parameters"];

    [self addSliderForProperty:note.frequency             title:@"Frequency"];
    [self addSliderForProperty:note.pluckPosition         title:@"Pluck Position"];
    [self addSliderForProperty:note.samplePosition        title:@"Sample Position"];
    [self addSliderForProperty:note.reflectionCoefficient title:@"Palm Muting"];
    [self addSliderForProperty:note.amplitude             title:@"Amplitude"];

    [self addAudioOutputRollingWaveformPlot];
    [self addAudioOutputPlot];
    [self addAudioOutputFFTPlot];
}

@end
