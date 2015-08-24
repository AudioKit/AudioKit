//
//  VibraphonePlayground.m
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

    AKVibraphoneInstrument *vibraphone = [[AKVibraphoneInstrument alloc] initWithNumber:1];
    [AKOrchestra addInstrument:vibraphone];

    AKAmplifier *amp = [[AKAmplifier alloc] initWithInput:vibraphone.output];
    amp.instrumentNumber = 2;
    [AKOrchestra addInstrument:amp];
    [amp start];

    AKVibraphoneNote *note = [[AKVibraphoneNote alloc] init];

    [self addButtonWithTitle:@"Play Once" block:^{ [vibraphone playNote:note]; }];

    [self addSliderForProperty:vibraphone.amplitude title:@"Amplitude"];

    AKPhrase *phrase = [[AKPhrase alloc] init];
    [phrase addNote:note];

    [self makeSection:@"Repeat Frequency"];
    [self addRepeatSliderForInstrument:vibraphone
                                phrase:phrase
                      minimumFrequency:0.0f
                      maximumFrequency:25.0f];

    [self addButtonWithTitle:@"Stop Loop" block:^{ [vibraphone stopPhrase]; }];

    [self makeSection:@"Parameters"];

    [self addSliderForProperty:note.frequency      title:@"Frequency"];
    [self addSliderForProperty:note.stickHardness  title:@"Stick Hardness"];
    [self addSliderForProperty:note.strikePosition title:@"Strike Position"];
    [self addSliderForProperty:note.amplitude      title:@"Amplitude"];

    [self addAudioOutputRollingWaveformPlot];
    [self addAudioOutputPlot];
    [self addAudioOutputFFTPlot];
}

@end
