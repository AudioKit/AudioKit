//
//  ToneGenerator.m
//  Objective-Csound Example
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ToneGenerator.h"
#import "OCSSineTable.h"
#import "OCSOscillator.h"
#import "OCSAudio.h"

@implementation ToneGenerator

@synthesize frequency;
@synthesize auxilliaryOutput;

- (id)init
{
    self = [super init];
    
    if (self) {       
        // INPUTS ==============================================================
        
        frequency  = [[OCSProperty alloc] initWithValue:220 minValue:kFrequencyMin  maxValue:kFrequencyMax];
        [frequency setControl:[OCSControl parameterWithString:@"InputFrequency"]]; 
        [self addProperty:frequency];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSSineTable *sine = [[OCSSineTable alloc] init];
        [sine setIsNormalized:YES];
        [self addFTable:sine];
        
        OCSOscillator *oscillator;
        oscillator = [[OCSOscillator alloc] initWithFTable:sine
                                                 frequency:[frequency control]
                                                 amplitude:ocsp(0.4)];
        [self addOpcode:oscillator];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio = [[OCSAudio alloc] initWithMonoInput:[oscillator output]]; 
        [self addOpcode:audio];
        
        
        // EXTERNAL OUTPUTS ====================================================        
        // After your instrument is set up, define outputs available to others
        auxilliaryOutput = [OCSParameter globalParameterWithString:@"ToneGeneratorOutput"];
        [self assignOutput:auxilliaryOutput To:[oscillator output]];
    }
    return self;
}

- (void)playNoteForDuration:(float)dur Frequency:(float)freq {
    frequency.value = freq;
    NSLog(@"Playing note at frequency = %0.2f", freq);
    [self playNoteForDuration:dur];
}

@end
