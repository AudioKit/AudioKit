//
//  TambourinePlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@implementation Playground

- (void)run
{
    [super run];

    AKTambourineInstrument * tambourine = [[AKTambourineInstrument alloc] initWithNumber:1];
    [AKOrchestra addInstrument:tambourine];

    AKAmplifier *amp = [[AKAmplifier alloc] initWithInput:tambourine.output];
    amp.instrumentNumber = 2;
    [AKOrchestra addInstrument:amp];
    [amp start];

    AKTambourineNote *note = [[AKTambourineNote alloc] init];

    [self addButtonWithTitle:@"Play Once" block:^{ [tambourine playNote:note]; }];

    [self addSliderForProperty:tambourine.amplitude title:@"Amplitude"];

    AKPhrase *phrase = [[AKPhrase alloc] init];
    [phrase addNote:note];

    [self makeSection:@"Repeat Frequency"];
    [self addRepeatSliderForInstrument:tambourine
                                phrase:phrase
                      minimumFrequency:0.0f
                      maximumFrequency:25.0f];

    [self addButtonWithTitle:@"Stop Loop" block:^{ [tambourine stopPhrase]; }];

    [self makeSection:@"Parameters"];

    [self addSliderForProperty:note.dampingFactor           title:@"Damping Factor"];
    [self addSliderForProperty:note.mainResonantFrequency   title:@"Main Resonant Freq."];
    [self addSliderForProperty:note.firstResonantFrequency  title:@"1st Resonant Freq."];
    [self addSliderForProperty:note.secondResonantFrequency title:@"2nd Resonant Freq."];

    [self addAudioOutputRollingWaveformPlot];
    [self addAudioOutputPlot];
    [self addAudioOutputFFTPlot];

}

@end
