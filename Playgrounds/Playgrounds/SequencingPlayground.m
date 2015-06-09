//
//  SequencingPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"
#import "AKFMOscillatorInstrument.h"

@implementation Playground {
    AKPhrase *phrase;
}

- (void)run
{
    [super run];

    phrase = [AKPhrase phrase];

    AKFMOscillatorInstrument *oscillator = [[AKFMOscillatorInstrument alloc] initWithNumber:1];
    [AKOrchestra addInstrument:oscillator];

    float duration = 0.1;

    [self addButtonWithTitle:@"Play Phrase Once" block:^{
        [oscillator playPhrase:[self phraseWithDuration:duration]];
    }];

    [self addButtonWithTitle:@"Loop Phrase" block:^{
        [oscillator repeatPhrase:[self phraseWithDuration:duration]];
    }];

    [self addButtonWithTitle:@"Stop Looping Phrase" block:^{
        [phrase reset];
        [oscillator stopPhrase];
    }];

    [self addAudioOutputRollingWaveformPlot];
    [self addAudioOutputPlot];
    [self addAudioOutputFFTPlot];
}

- (AKPhrase *)phraseWithDuration:(float)duration
{
    [phrase reset];
    for (int i = 0; i <= 12 ; i++) {
        AKFMOscillatorNote *note = [[AKFMOscillatorNote alloc] init];
        note.frequency.value = 440*(pow(2.0f,(float)i/12));
        note.duration.value = duration;
        [phrase addNote:note atTime:i*duration];
    }
    return phrase;
}

@end
