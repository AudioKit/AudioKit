//
//  FMGameObject.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "FMGameObject.h"
//
//typedef enum { kDurationArg, kFrequencyArg, kModulationArg } FMGameObjectArguments;

@implementation FMGameObject
@synthesize frequency;
@synthesize modulation;

-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra {
    self = [super initWithOrchestra:newOrchestra];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
        frequency  = [[CSDProperty alloc] init];
        modulation = [[CSDProperty alloc] init];
        
        //Optional output string assignment, can make for a nicer to read CSD File
        [frequency  setOutput:[CSDParamControl paramWithString:@"Frequency"]]; 
        [modulation setOutput:[CSDParamControl paramWithString:@"Modulation"]]; 
        
        [self addProperty:frequency];
        [self addProperty:modulation];
        
        // INSTRUMENT DEFINITION ===============================================
            
        CSDSineTable *sineTable = [[CSDSineTable alloc] init];
        [self addFunctionTable:sineTable];
        
        CSDFoscili * myFMOscillator = 
        [[CSDFoscili alloc] initWithAmplitude:[CSDParamConstant paramWithFloat:0.4]
                                    Frequency:[frequency output]
                                      Carrier:[CSDParamConstant paramWithInt:1]
                                   Modulation:[modulation output]
                                     ModIndex:[CSDParamConstant paramWithInt:15]
                                FunctionTable:sineTable
                             AndOptionalPhase:nil];
        [self addOpcode:myFMOscillator];
        
        // AUDIO OUTPUT ========================================================
        
        CSDOutputStereo * monoOutput = 
        [[CSDOutputStereo alloc] initWithMonoInput:[myFMOscillator output]];
        [self addOpcode:monoOutput];
    }
    return self;
}

-(void) playNoteForDuration:(float)dur Frequency:(float)freq Modulation:(float)mod {
    frequency.value = freq;
    modulation.value = mod;
    [self playNoteWithDuration:dur];
}

                    
@end
