//
//  StruckMetalBarPlayground.m
//  AudioKit
//
//  Created by Nick Arner on 3/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"
#import "StruckMetalBar.h"

@implementation Playground {
    StruckMetalBar *struckMetalBar;
    StruckMetalBarNote *note;
}

- (void) setup
{
    [super setup];

}

- (void)run
{
    [super run];
    struckMetalBar = [[StruckMetalBar alloc] init];
    [AKOrchestra addInstrument:struckMetalBar];

    [self addAudioOutputPlot];
    note = [[StruckMetalBarNote alloc] init];

    [self addButtonWithTitle:@"Play Once" block:^{ [struckMetalBar playNote:note]; }];

    [self addSliderForProperty:struckMetalBar.amplitude title:@"Amplitude"];

    AKPhrase *phrase = [[AKPhrase alloc] init];
    [phrase addNote:note];


    [self makeSection:@"Repeat Frequency"];
    [self addRepeatSliderForInstrument:struckMetalBar
                                phrase:phrase
                      minimumFrequency:0.0f
                      maximumFrequency:25.0f];

    [self addButtonWithTitle:@"Stop Loop" block:^{ [struckMetalBar stopPhrase]; }];

    [self makeSection:@"Parameters"];

    [self addSliderForProperty:note.dimensionlessStiffness title:@"Stiffness"];
    [self addSliderForProperty:note.highFrequencyLoss      title:@"High Freq. Loss"];
    [self addSliderForProperty:note.strikePosition         title:@"Strike Position"];
    [self addSliderForProperty:note.strikeVelocity         title:@"Strike Velocity"];
    [self addSliderForProperty:note.strikeWidth            title:@"Strike Width"];
    [self addSliderForProperty:note.scanSpeed              title:@"Scan Speed"];
}

@end
