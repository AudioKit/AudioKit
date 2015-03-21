//
//  BamboosSticksPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"
#import "BambooSticks.h"

@implementation Playground {
    BambooSticks *bambooSticks;
    BambooSticksNote *note;
}

- (void) setup
{
    [super setup];

}


- (void)run
{
    [super run];
    bambooSticks = [[BambooSticks alloc] init];
    [AKOrchestra addInstrument:bambooSticks];
    
    [self addStereoAudioOutputPlot];
    note = [[BambooSticksNote alloc] init];
    AKPlaygroundButton(@"Play Once", [bambooSticks playNote:note];);
    
    AKPlaygroundPropertySlider(volume, bambooSticks.amplitude);
    
    AKPhrase *phrase = [[AKPhrase alloc] init];
    [phrase addNote:note];
    
    
    [self makeSection:@"Repeat Frequency"];
    [self addRepeatSliderForInstrument:bambooSticks
                                phrase:phrase
                      minimumFrequency:0.0f
                      maximumFrequency:25.0f];
    
    AKPlaygroundButton(@"Stop Loop",  [bambooSticks stopPhrase];);
    
    [self makeSection:@"Parameters"];
    AKPlaygroundPropertySlider(intensity, note.count);
    AKPlaygroundPropertySlider(mainResFreq, note.mainResonantFrequency);
    AKPlaygroundPropertySlider(firstResFreq, note.firstResonantFrequency);
    AKPlaygroundPropertySlider(secondResFreq, note.secondResonantFrequency);
    AKPlaygroundPropertySlider(amplitude, note.amplitude);
}

@end
