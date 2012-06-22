//
//  FMGameObject.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "FMGameObject.h"

@implementation FMGameObject
@synthesize frequency;
@synthesize modulation;

-(id) initWithOrchestra:(OCSOrchestra *)newOrchestra {
    self = [super initWithOrchestra:newOrchestra];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
        frequency  = [[OCSProperty alloc] init];
        modulation = [[OCSProperty alloc] init];
        
        //Optional output string assignment, can make for a nicer to read CSD File
        [frequency  setOutput:[OCSParamControl paramWithString:@"Frequency"]]; 
        [modulation setOutput:[OCSParamControl paramWithString:@"Modulation"]]; 
        
        [self addProperty:frequency];
        [self addProperty:modulation];
        
        // INSTRUMENT DEFINITION ===============================================
            
        OCSSineTable *sineTable = [[OCSSineTable alloc] init];
        [self addFunctionTable:sineTable];
        
        OCSFoscili * myFMOscillator = 
        [[OCSFoscili alloc] initWithAmplitude:[OCSParamConstant paramWithFloat:0.4]
                                    Frequency:[frequency output]
                                      Carrier:[OCSParamConstant paramWithInt:1]
                                   Modulation:[modulation output]
                                     ModIndex:[OCSParamConstant paramWithInt:15]
                                FunctionTable:sineTable
                             AndOptionalPhase:nil];
        [self addOpcode:myFMOscillator];
        
        // AUDIO OUTPUT ========================================================
        
        OCSOutputStereo * monoOutput = 
        [[OCSOutputStereo alloc] initWithMonoInput:[myFMOscillator output]];
        [self addOpcode:monoOutput];
    }
    return self;
}

-(void) playNoteForDuration:(float)dur Frequency:(float)freq Modulation:(float)mod {
    frequency.value = freq;
    modulation.value = mod;
    [self playNoteForDuration:dur];
}

                    
@end
