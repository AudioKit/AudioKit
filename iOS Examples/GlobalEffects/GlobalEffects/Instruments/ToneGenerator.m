//
//  ToneGenerator.m
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ToneGenerator.h"

@implementation ToneGenerator

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        // INPUTS ==============================================================
        
        _frequency  = [[AKInstrumentProperty alloc] initWithValue:220
                                                     minimumValue:110
                                                     maximumValue:880];
        [self addProperty:_frequency];
        
        // INSTRUMENT DEFINITION ===============================================
        
        AKSineTable *sine = [[AKSineTable alloc] init];
        [sine setIsNormalized:YES];
        [self addFTable:sine];
        
        AKOscillator *oscillator;
        oscillator = [[AKOscillator alloc] initWithFTable:sine
                                                frequency:_frequency
                                                amplitude:akp(0.2)];
        [self connect:oscillator];
        
        // AUDIO OUTPUT ========================================================
        
        AKAudioOutput *audio = [[AKAudioOutput alloc] initWithAudioSource:oscillator];
        [self connect:audio];
        
        
        // EXTERNAL OUTPUTS ====================================================
        // After your instrument is set up, define outputs available to others
        _auxilliaryOutput = [AKAudio globalParameter];
        [self assignOutput:_auxilliaryOutput to:oscillator];
    }
    return self;
}

@end
