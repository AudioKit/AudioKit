//
//  SequencingPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"
#import "FMOscillatorInstrument.h"

@implementation Playground {
    FMOscillatorInstrument *oscillator;
    AKPhrase *phrase;
}


- (void) setup
{
    [super setup];
    phrase = [AKPhrase phrase];
}

- (void)run
{
    [super run];
    
    oscillator = [[FMOscillatorInstrument alloc] initWithNumber:1];
    [AKOrchestra addInstrument:oscillator];
    
    
    float duration = 0.1;
    
    AKPlaygroundButton(@"Play Phrase Once",
                       [oscillator playPhrase:[self phraseWithDuration:duration]];
                       );
    
    AKPlaygroundButton(@"Loop Phrase",
                       [oscillator repeatPhrase:[self phraseWithDuration:duration]];
                       );
    AKPlaygroundButton(@"Stop Looping Phrase",
                       [phrase reset];
                       [oscillator stopPhrase];
                       );
}



- (AKPhrase *)phraseWithDuration:(float)duration
{
    [phrase reset];
    for (int i = 0; i <= 12 ; i++) {
        FMOscillatorNote *note = [[FMOscillatorNote alloc] init];
        note.frequency.value = 440*(pow(2.0f,(float)i/12));
        note.duration.value = duration;
        [phrase addNote:note atTime:i*duration];
    }
    return phrase;
}

@end
