//
//  ToneGenerator.m
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ToneGenerator.h"
#import "OCSSineTable.h"
#import "OCSOscillator.h"
#import "OCSAudioOutput.h"

@interface ToneGenerator () {
    OCSAudio *auxilliaryOutput;
}
@end

@implementation ToneGenerator

@synthesize frequency;
@synthesize auxilliaryOutput;

- (id)init
{
    self = [super init];
    
    if (self) {       
        // INPUTS ==============================================================
        
        frequency  = [[OCSInstrumentProperty alloc] initWithValue:220 minValue:kFrequencyMin  maxValue:kFrequencyMax];
        [self addProperty:frequency];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSSineTable *sine = [[OCSSineTable alloc] init];
        [sine setIsNormalized:YES];
        [self addFTable:sine];
        
        OCSOscillator *oscillator;
        oscillator = [[OCSOscillator alloc] initWithFTable:sine
                                                 frequency:frequency
                                                 amplitude:ocsp(0.2)];
        [self connect:oscillator];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudioOutput *audio = [[OCSAudioOutput alloc] initWithMonoInput:oscillator]; 
        [self connect:audio];
        
        
        // EXTERNAL OUTPUTS ====================================================        
        // After your instrument is set up, define outputs available to others
        auxilliaryOutput = [OCSAudio globalParameter];
        [self assignOutput:auxilliaryOutput to:oscillator];
    }
    return self;
}

@end
