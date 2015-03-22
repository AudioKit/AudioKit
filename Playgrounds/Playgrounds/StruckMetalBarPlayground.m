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
    AKPlaygroundButton(@"Play Once", [struckMetalBar playNote:note];);

    AKPlaygroundPropertySlider(volume, struckMetalBar.amplitude);

    AKPhrase *phrase = [[AKPhrase alloc] init];
    [phrase addNote:note];


    [self makeSection:@"Repeat Frequency"];
    [self addRepeatSliderForInstrument:struckMetalBar
                                phrase:phrase
                      minimumFrequency:0.0f
                      maximumFrequency:25.0f];

    AKPlaygroundButton(@"Stop Loop",  [struckMetalBar stopPhrase];);

    [self makeSection:@"Parameters"];
    AKPlaygroundPropertySlider(frequency, note.dimensionlessStiffness);
    AKPlaygroundPropertySlider(hfLoss, note.highFrequencyLoss);
    AKPlaygroundPropertySlider(strikePosition, note.strikePosition);
    AKPlaygroundPropertySlider(strikeVelocity, note.strikeVelocity);
    AKPlaygroundPropertySlider(strikeWidth, note.strikeWidth);
    AKPlaygroundPropertySlider(scanSpeed, note.scanSpeed);

}

@end
