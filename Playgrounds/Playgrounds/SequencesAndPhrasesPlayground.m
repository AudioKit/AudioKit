//
//  SequencesAndPhrasesPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@implementation Playground {
    AKSequence *sequence;
    AKMandolinInstrument *mandolin;
}

- (void) setup
{
    [super setup];
    sequence = [AKSequence sequence];
    mandolin = [[AKMandolinInstrument alloc] initWithNumber:1];

    mandolin.amplitude.minimum = 0.25;
    mandolin.amplitude.maximum = 0.75;

    mandolin.bodySize.minimum = 0.25;
    mandolin.bodySize.maximum = 0.6;
    [AKOrchestra addInstrument:mandolin];


    AKAmplifier *amp = [[AKAmplifier alloc] initWithInput:mandolin.output];
    amp.instrumentNumber = 2;
    [AKOrchestra addInstrument:amp];
    [amp start];
}

- (void)run
{
    [super run];

    AKPhrase *phrase = [AKPhrase phrase];
    AKMandolinNote *note1 = [[AKMandolinNote alloc] init];
    note1.frequency.value = 440;
    [phrase addNote:note1];

    AKMandolinNote *note2 = [[AKMandolinNote alloc] init];
    note2.frequency.value = 660;
    [phrase addNote:note2 atTime:0.25];

    AKMandolinNote *note3 = [[AKMandolinNote alloc] init];
    note3.frequency.value = 880;
    [phrase addNote:note3 atTime:0.5];

    AKMandolinNote *note4 = [[AKMandolinNote alloc] init];
    note4.frequency.value = 660;
    [phrase addNote:note4 atTime:0.75];

    [self addButtonWithTitle:@"Loop Phrase" block:^{
        [sequence stop];
        [mandolin repeatPhrase:phrase duration:1.0];
    }];

    [self addButtonWithTitle:@"Stop Phrase Loop" block:^{ [mandolin stopPhrase]; }];

    [self addSliderForProperty:note1.frequency title:@"note1 frequency"];
    [self addSliderForProperty:note2.frequency title:@"note2 frequency"];
    [self addSliderForProperty:note3.frequency title:@"note3 frequency"];
    [self addSliderForProperty:note4.frequency title:@"note4 frequency"];

    [self makeSection:@"Sequence randomly pulling notes from sliders above"];

    [sequence stop];

    AKEvent *playRandomNote = [[AKEvent alloc] initWithBlock:^{
        [mandolin.amplitude randomize];
        [mandolin.bodySize randomize];
        switch (arc4random_uniform(4)) {
            case 0:
                [mandolin playNote:note1];
                break;

            case 1:
                [mandolin playNote:note2];
                break;

            case 2:
                [mandolin playNote:note3];
                break;

            case 3:
                [mandolin playNote:note4];
                break;

            default:
                break;
        }
    }];

    [sequence addEvent:playRandomNote];


    [self addButtonWithTitle:@"Loop Sequence" block:^{
        [mandolin stopPhrase];
        [sequence loopWithLoopDuration:0.25];
    }];

    [self addButtonWithTitle:@"Stop Sequence" block:^{ [sequence stop]; }];


    [self addSliderForProperty:mandolin.amplitude            title:@"Amplitude"];
    [self addSliderForProperty:mandolin.bodySize             title:@"Body Size"];
    [self addSliderForProperty:mandolin.pairedStringDetuning title:@"Detuning"];
 }

@end
