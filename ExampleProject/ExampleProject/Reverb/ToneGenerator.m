//
//  ToneGenerator.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ToneGenerator.h"

@implementation ToneGenerator
@synthesize frequency;
@synthesize auxilliaryOutput;

-(id) initWithOrchestra:(OCSOrchestra *)newOrchestra
{
    self = [super initWithOrchestra:newOrchestra];
    if (self) {       
        // INPUTS ==============================================================
        
        frequency  = [[OCSProperty alloc] init];
        [frequency setOutput:[OCSParamControl paramWithString:@"InputFrequency"]]; //Optional
        [self addProperty:frequency];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSSineTable * sineTable = [[OCSSineTable alloc] init];
        [self addFunctionTable:sineTable];
        
        OCSOscillator * myOscillator = 
        [[OCSOscillator alloc] initWithAmplitude:[OCSParamConstant paramWithFloat:0.4]
                                       Frequency:[frequency output]
                                   FunctionTable:sineTable];
        [self addOpcode:myOscillator];
        
        // AUDIO OUTPUT ========================================================
        
        OCSOutputStereo * stereoOutput = 
        [[OCSOutputStereo alloc] initWithMonoInput:[myOscillator output]]; 
        [self addOpcode:stereoOutput];
        
        
        // EXTERNAL OUTPUTS ====================================================        
        // After your instrument is set up, define outputs available to others
        auxilliaryOutput = [OCSParam paramWithString:@"ToneGeneratorOutput"];
        [self assignOutput:auxilliaryOutput To:[myOscillator output]];
    }
    return self;
}

-(void) playNoteForDuration:(float)dur Frequency:(float)freq {
    frequency.value = freq;
    [self playNoteForDuration:dur];
}

@end
