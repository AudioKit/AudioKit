//
//  SleighbellsPlayground.m
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

    AKSleighbellsInstrument *sleighBells = [[AKSleighbellsInstrument alloc] initWithNumber:1];
    [AKOrchestra addInstrument:sleighBells];

    AKAmplifier *amp = [[AKAmplifier alloc] initWithInput:sleighBells.output];
    amp.instrumentNumber = 2;
    [AKOrchestra addInstrument:amp];
    [amp start];

    AKSleighbellsNote *note = [[AKSleighbellsNote alloc] init];

    [self addButtonWithTitle:@"Play Once" block:^{ [sleighBells playNote:note]; }];

    [self addSliderForProperty:sleighBells.amplitude title:@"Amplitude"];

    AKPhrase *phrase = [[AKPhrase alloc] init];
    [phrase addNote:note];

    [self makeSection:@"Repeat Frequency"];
    [self addRepeatSliderForInstrument:sleighBells
                                phrase:phrase
                      minimumFrequency:0.0f
                      maximumFrequency:25.0f];

    [self addButtonWithTitle:@"Stop Loop" block:^{ [sleighBells stopPhrase]; }];

    [self makeSection:@"Parameters"];

    [self addSliderForProperty:note.intensity               title:@"Intensity"];
    [self addSliderForProperty:note.dampingFactor           title:@"Damping Factor"];
    [self addSliderForProperty:note.mainResonantFrequency   title:@"Main Resonant Freq."];
    [self addSliderForProperty:note.firstResonantFrequency  title:@"1st Resonant Freq."];
    [self addSliderForProperty:note.secondResonantFrequency title:@"2nd Resonant Freq."];
    [self addSliderForProperty:note.amplitude               title:@"Amplitude"];

    [self addAudioOutputRollingWaveformPlot];
    [self addAudioOutputPlot];
    [self addAudioOutputFFTPlot];
}

@end
