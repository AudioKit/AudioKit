//
//  StickPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"
#import "Stick.h"

@implementation Playground {
    Stick *stick;
    StickNote *note;
}

- (void) setup
{
    [super setup];

}

- (void)run
{
    [super run];
    stick = [[Stick alloc] init];
    [AKOrchestra addInstrument:stick];
    
    [self addStereoAudioOutputPlot];
    note = [[StickNote alloc] init];
    AKPlaygroundButton(@"Play Once", [stick playNote:note];);
    
    AKPlaygroundPropertySlider(volume, stick.amplitude);
    
    AKPhrase *phrase = [[AKPhrase alloc] init];
    [phrase addNote:note];
    
    
    [self makeSection:@"Repeat Frequency"];
    [self addRepeatSliderForInstrument:stick
                                phrase:phrase
                      minimumFrequency:0.0f
                      maximumFrequency:25.0f];
    
    AKPlaygroundButton(@"Stop Loop",  [stick stopPhrase];);
    
    [self makeSection:@"Parameters"];
    AKPlaygroundPropertySlider(intensity, note.intensity);
    AKPlaygroundPropertySlider(dampingFactor, note.dampingFactor);
    AKPlaygroundPropertySlider(amplitude, note.amplitude);
}

@end
