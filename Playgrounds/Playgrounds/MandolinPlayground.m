//
//  MandolinPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"
#import "Mandolin.h"

@implementation Playground {
    Mandolin *mandolin;
    MandolinNote *note;
}

- (void) setup
{
    [super setup];

}

- (void)run
{
    [super run];
    mandolin = [[Mandolin alloc] init];
    [AKOrchestra addInstrument:mandolin];
    
    [self addStereoAudioOutputPlot];
    note = [[MandolinNote alloc] init];
    AKPlaygroundButton(@"Play Once", [mandolin playNote:note];);
    
    AKPlaygroundPropertySlider(volume, mandolin.amplitude);
    AKPlaygroundPropertySlider(bodySize, mandolin.bodySize);
    AKPlaygroundPropertySlider(detuning, mandolin.pairedStringDetuning);
    
    AKPhrase *phrase = [[AKPhrase alloc] init];
    [phrase addNote:note];
    
    
    [self makeSection:@"Repeat Frequency"];
    [self addRepeatSliderForInstrument:mandolin
                                phrase:phrase
                      minimumFrequency:0.0f
                      maximumFrequency:25.0f];
    
    AKPlaygroundButton(@"Stop Loop",  [mandolin stopPhrase];);
    
    [self makeSection:@"Parameters"];
    AKPlaygroundPropertySlider(frequency, note.frequency);
    AKPlaygroundPropertySlider(pluckPosition, note.pluckPosition);
    AKPlaygroundPropertySlider(amplitude, note.amplitude);
}

@end
