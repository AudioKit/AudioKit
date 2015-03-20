//
//  VibraphonePlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"
#import "Vibraphone.h"

@implementation Playground {
    Vibraphone *vibraphone;
    VibraphoneNote *note;
}

- (void) setup
{
    [super setup];

}

- (void)run
{
    [super run];
    vibraphone = [[Vibraphone alloc] init];
    [AKOrchestra addInstrument:vibraphone];
    
    [self addStereoAudioOutputPlot];
    note = [[VibraphoneNote alloc] init];
    AKPlaygroundButton(@"Play Once", [vibraphone playNote:note];);
    
    AKPlaygroundPropertySlider(volume, vibraphone.amplitude);
    
    AKPhrase *phrase = [[AKPhrase alloc] init];
    [phrase addNote:note];
    
    
    [self makeSection:@"Repeat Frequency"];
    [self addRepeatSliderForInstrument:vibraphone
                                phrase:phrase
                      minimumFrequency:0.0f
                      maximumFrequency:25.0f];
    
    AKPlaygroundButton(@"Stop Loop",  [vibraphone stopPhrase];);
    
    [self makeSection:@"Parameters"];
    AKPlaygroundPropertySlider(frequency, note.frequency);
    AKPlaygroundPropertySlider(stickHardness, note.stickHardness);
    AKPlaygroundPropertySlider(strikePosition, note.strikePosition);
    AKPlaygroundPropertySlider(amplitude, note.amplitude);
}

@end
