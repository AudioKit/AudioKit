//
//  SleighbellsPlayground.m
//  AudioKit
//
//  Created by Nick Arner on 3/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"
#import "Sleighbells.h"

@implementation Playground {
    Sleighbells *sleighBells;
    SleighbellsNote *note;
}

- (void) setup
{
    [super setup];
    sleighBells = [[Sleighbells alloc] init];
    [AKOrchestra addInstrument:sleighBells];
}

- (void)run
{
    [super run];
    [self addAudioOutputPlot];

    note = [[SleighbellsNote alloc] init];
    AKPlaygroundButton(@"Play Once", [sleighBells playNote:note];);

    AKPlaygroundPropertySlider(volume, sleighBells.amplitude);

    AKPhrase *phrase = [[AKPhrase alloc] init];


    [self makeSection:@"Repeat Frequency"];
    [self addRepeatSliderForInstrument:sleighBells
                                phrase:phrase
                      minimumFrequency:0.0f
                      maximumFrequency:25.0f];

    AKPlaygroundButton(@"Stop Loop",  [sleighBells stopPhrase];);

    [self makeSection:@"Parameters"];
    AKPlaygroundPropertySlider(intensity,   note.intensity);
    AKPlaygroundPropertySlider(damping,     note.dampingFactor);
    AKPlaygroundPropertySlider(mainResFreq, note.mainResonantFrequency);
    AKPlaygroundPropertySlider(resFreq1,    note.firstResonantFrequency);
    AKPlaygroundPropertySlider(resFreq2,    note.secondResonantFrequency);
    AKPlaygroundPropertySlider(amplitude,   note.amplitude);
}

@end
