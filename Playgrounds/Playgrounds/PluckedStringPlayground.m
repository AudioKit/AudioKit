//
//  PluckedString.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"
#import "PluckedString.h"

@implementation Playground {
    PluckedString *pluckedString;
    PluckedStringNote *note;
}

- (void) setup
{
    [super setup];

}

- (void)run
{
    [super run];
    pluckedString = [[PluckedString alloc] init];
    [AKOrchestra addInstrument:pluckedString];
    
    [self addStereoAudioOutputPlot];
    note = [[PluckedStringNote alloc] init];
    AKPlaygroundButton(@"Play Once", [pluckedString playNote:note];);
    
    AKPlaygroundPropertySlider(volume, pluckedString.amplitude);
    
    AKPhrase *phrase = [[AKPhrase alloc] init];
    [phrase addNote:note];
    
    
    [self makeSection:@"Repeat Frequency"];
    [self addRepeatSliderForInstrument:pluckedString
                                phrase:phrase
                      minimumFrequency:0.0f
                      maximumFrequency:25.0f];
    
    AKPlaygroundButton(@"Stop Loop",  [pluckedString stopPhrase];);
    
    [self makeSection:@"Parameters"];
    AKPlaygroundPropertySlider(frequency, note.frequency);
    AKPlaygroundPropertySlider(pluckPosition, note.pluckPosition);
    AKPlaygroundPropertySlider(samplePosition, note.samplePosition);
    AKPlaygroundPropertySlider(reflectionCoeff, note.reflectionCoefficient);
    AKPlaygroundPropertySlider(amplitude, note.amplitude);
}

@end
