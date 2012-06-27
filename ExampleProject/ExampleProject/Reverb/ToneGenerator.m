//
//  ToneGenerator.m
//  ExampleProject
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
        
        frequency  = [[OCSProperty alloc] init];
        [frequency setOutput:[OCSParamControl paramWithString:@"InputFrequency"]]; //Optional
        [self addProperty:frequency];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSSineTable *sineTable = [[OCSSineTable alloc] init];
        [self addFunctionTable:sineTable];
        
        OCSOscillator *myOscillator = [[OCSOscillator alloc] initWithFunctionTable:sineTable
                                                                         Amplitude:ocsp(0.4)
                                                                         Frequency:[frequency output]];
        [self addOpcode:myOscillator];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio = [[OCSAudio alloc] initWithMonoInput:[myOscillator output]]; 
        [self addOpcode:audio];
        
        
        // EXTERNAL OUTPUTS ====================================================        
        // After your instrument is set up, define outputs available to others
        auxilliaryOutput = [OCSParam paramWithString:@"ToneGeneratorOutput"];
        [self assignOutput:auxilliaryOutput To:[myOscillator output]];
    }
    return self;
}

- (void)playNoteForDuration:(float)dur Frequency:(float)freq {
    frequency.value = freq;
    NSLog(@"Playing note at frequency = %0.2f", freq);
    [self playNoteForDuration:dur];
}

@end
