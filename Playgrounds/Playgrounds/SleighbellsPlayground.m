//
//  SleighbellsPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/15/15.
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

}


- (void)run
{
    [super run];
    sleighBells = [[Sleighbells alloc] init];
    [AKOrchestra addInstrument:sleighBells];
    
    [self addStereoAudioOutputPlot];
    note = [[SleighbellsNote alloc] init];
    AKPlaygroundButton(@"Play Once", [sleighBells playNote:note];);
    
    AKPlaygroundPropertySlider(volume, sleighBells.amplitude);
    
    AKPhrase *phrase = [[AKPhrase alloc] init];
    [phrase addNote:note];
    
    
    [self makeSection:@"Repeat Frequency"];
    [self addRepeatSliderForInstrument:sleighBells
                                phrase:phrase
                      minimumFrequency:0.0f
                      maximumFrequency:25.0f];
    
    AKPlaygroundButton(@"Stop Loop",  [sleighBells stopPhrase];);
    
    [self makeSection:@"Parameters"];
    AKPlaygroundPropertySlider(intensity, note.intensity);
    AKPlaygroundPropertySlider(damping, note.dampingFactor);
    AKPlaygroundPropertySlider(mainResFreq, note.mainResonantFrequency);
    AKPlaygroundPropertySlider(firstResFreq, note.firstResonantFrequency);
    AKPlaygroundPropertySlider(secondResFreq, note.secondResonantFrequency);
    AKPlaygroundPropertySlider(amplitude, note.amplitude);
    
}

@end
