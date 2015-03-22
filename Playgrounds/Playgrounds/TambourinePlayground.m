//
//  TambourinePlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"
#import "Tambourine.h"

@implementation Playground {
    Tambourine *tambourine;
    TambourineNote *note;
}

- (void) setup
{
    [super setup];
    tambourine = [[Tambourine alloc] init];
    [AKOrchestra addInstrument:tambourine];
}

- (void)run
{
    [super run];
    [self addAudioOutputPlot];
    note = [[TambourineNote alloc] init];

    [self addButtonWithTitle:@"Play Once" block:^{
        [tambourine playNote:note];
    }];

    AKPlaygroundPropertySlider(volume, tambourine.amplitude);

    AKPhrase *phrase = [[AKPhrase alloc] init];
    [phrase addNote:note];

    [self makeSection:@"Repeat Frequency"];
    [self addRepeatSliderForInstrument:tambourine
                                phrase:phrase
                      minimumFrequency:0.0f
                      maximumFrequency:25.0f];

    [self addButtonWithTitle:@"Stop Loop" block:^{
        [tambourine stopPhrase];
    }];

    [self makeSection:@"Parameters"];
    AKPlaygroundPropertySlider(dampingFactor, note.dampingFactor);
    AKPlaygroundPropertySlider(resFreqMain,   note.mainResonantFrequency);
    AKPlaygroundPropertySlider(resFreq1,      note.firstResonantFrequency);
    AKPlaygroundPropertySlider(resFreq2,      note.secondResonantFrequency);
}

@end
