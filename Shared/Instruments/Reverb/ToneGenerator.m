//
//  ToneGenerator.m
//  Objective-C Sound Example
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
        
        _frequency  = [[OCSInstrumentProperty alloc] initWithValue:220
                                                      minimumValue:kFrequencyMin
                                                      maximumValue:kFrequencyMax];
        [self addProperty:_frequency];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSSineTable *sine = [[OCSSineTable alloc] init];
        [sine setIsNormalized:YES];
        [self addFTable:sine];
        
        OCSOscillator *oscillator;
        oscillator = [[OCSOscillator alloc] initWithFTable:sine
                                                 frequency:_frequency
                                                 amplitude:ocsp(0.2)];
        [self connect:oscillator];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudioOutput *audio = [[OCSAudioOutput alloc] initWithAudioSource:oscillator];
        [self connect:audio];
        
        
        // EXTERNAL OUTPUTS ====================================================
        // After your instrument is set up, define outputs available to others
        _auxilliaryOutput = [OCSAudio globalParameter];
        [self assignOutput:_auxilliaryOutput to:oscillator];
    }
    return self;
}

@end
