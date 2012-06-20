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

-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra
{
    self = [super initWithOrchestra:newOrchestra];
    if (self) {       
        // INPUTS ==============================================================
        
        frequency  = [[CSDProperty alloc] init];
        [frequency setOutput:[CSDParamControl paramWithString:@"InputFrequency"]]; //Optional
        [self addProperty:frequency];
        
        // INSTRUMENT DEFINITION ===============================================
        
        //auxilliaryOutput = [CSDParam paramWithString:@"OscillatorOutput"];
        CSDSineTable * sineTable = [[CSDSineTable alloc] init];
        [self addFunctionTable:sineTable];
        
        CSDOscillator * myOscillator = 
        [[CSDOscillator alloc] initWithAmplitude:[CSDParamConstant paramWithFloat:0.1]
                                       Frequency:[frequency output]
                                   FunctionTable:sineTable];
        //[myOscillator setOutput:auxilliaryOutput];
        [self addOpcode:myOscillator];

        CSDOutputStereo * stereoOutput = 
        [[CSDOutputStereo alloc] initWithMonoInput:[myOscillator output]]; 
        [self addOpcode:stereoOutput];
        
        
        // OUTPUTS =============================================================
        
        //After your instrument is set up, define outputs available to others
        //Perhaps this is another place where CSDProperty could be used with chnset
        auxilliaryOutput = [CSDParam paramWithString:@"ToneGeneratorOutput"];
        [self assignOutput:auxilliaryOutput To:[myOscillator output]];
    }
    return self;
}

-(void) playNoteForDuration:(float)dur Frequency:(float)freq {
    frequency.value = freq;
    [self playNoteWithDuration:dur];
}

@end
