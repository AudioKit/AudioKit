//
//  SekerePlayground.m
//  AudioKit
//
//  Created by Nick Arner on 3/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"
#import "Sekere.h"

@implementation Playground {
    Sekere *sekere;
    SekereNote *note;
}

- (void) setup
{
    [super setup];
    sekere = [[Sekere alloc] init];
    [AKOrchestra addInstrument:sekere];
}

- (void)run
{
    [super run];
    [self addStereoAudioOutputPlot];
    note = [[SekereNote alloc] init];
    AKPlaygroundButton(@"Play Once", [sekere playNote:note];);
    
    AKPlaygroundPropertySlider(volume, sekere.amplitude);
    
    AKPhrase *phrase = [[AKPhrase alloc] init];
    [phrase addNote:note];
    
    
    [self makeSection:@"Repeat Frequency"];
    [self addRepeatSliderForInstrument:sekere
                                phrase:phrase
                      minimumFrequency:1.0f
                      maximumFrequency:25.0f];
    
    AKPlaygroundButton(@"Stop Loop",  [sekere stopPhrase];);
    
    [self makeSection:@"Parameters"];
    AKPlaygroundPropertySlider(count, note.count);
    AKPlaygroundPropertySlider(dampingFactor, note.dampingFactor);
    AKPlaygroundPropertySlider(amplitude, note.amplitude);
}

@end
