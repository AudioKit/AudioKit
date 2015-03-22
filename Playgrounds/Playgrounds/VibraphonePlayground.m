//
//  VibraphonePlayground.m
//  AudioKit
//
//  Created by Nick Arner on 3/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"
#import "Marimba.h"

@implementation Playground {
    Marimba *marimba;
    MarimbaNote *note;
}

- (void) setup
{
    [super setup];

}

- (void)run
{
    [super run];
    marimba = [[Marimba alloc] init];
    [AKOrchestra addInstrument:marimba];

    [self addAudioOutputPlot];
    note = [[MarimbaNote alloc] init];
    AKPlaygroundButton(@"Play Once", [marimba playNote:note];);

    AKPlaygroundPropertySlider(volume, marimba.amplitude);
    AKPlaygroundPropertySlider(vibratoFreq, marimba.vibratoFrequency);
    AKPlaygroundPropertySlider(vibratoAmp, marimba.vibratoAmplitude);

    AKPhrase *phrase = [[AKPhrase alloc] init];
    [phrase addNote:note];

    [self makeSection:@"Repeat Frequency"];
    [self addRepeatSliderForInstrument:marimba
                                phrase:phrase
                      minimumFrequency:0.0f
                      maximumFrequency:25.0f];

    AKPlaygroundButton(@"Stop Loop",  [marimba stopPhrase];);

    [self makeSection:@"Parameters"];
    AKPlaygroundPropertySlider(frequency, note.frequency);
    AKPlaygroundPropertySlider(stickHardness, note.stickHardness);
    AKPlaygroundPropertySlider(strikePosition, note.strikePosition);
    AKPlaygroundPropertySlider(amplitude, note.amplitude);
}

@end
