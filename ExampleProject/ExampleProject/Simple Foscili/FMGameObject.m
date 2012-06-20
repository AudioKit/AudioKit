//
//  FMGameObject.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "FMGameObject.h"

typedef enum { kDurationArg, kFrequencyArg, kModulationArg } FMGameObjectArguments;

@implementation FMGameObject

-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra {
    self = [super initWithOrchestra:newOrchestra];
    if (self) {
        //define opcodes with properties connected to gameBehavior
    
        CSDSineTable *sineTable = [[CSDSineTable alloc] init];
        [self addFunctionTable:sineTable];
        
        CSDFoscili * myFoscilOpcode = [[CSDFoscili alloc] 
                          initFMOscillatorWithAmplitude:[CSDParamConstant paramWithFloat:0.4]
                                              Frequency:[CSDParamConstant paramWithPValue:kFrequencyArg]
                                                Carrier:[CSDParamConstant paramWithInt:1]
                                             Modulation:[CSDParamConstant paramWithPValue:kModulationArg]
                                               ModIndex:[CSDParamConstant paramWithInt:15]
                                          FunctionTable:sineTable
                                        AndOptionalPhase:nil];
        [self addOpcode:myFoscilOpcode];
        CSDOutputStereo * monoOutput = [[CSDOutputStereo alloc] initWithMonoInput:[myFoscilOpcode output]];
        [self addOpcode:monoOutput];
    }
    return self;
}

-(void) playNoteForDuration:(float)dur Frequency:(float)freq Modulation:(float)mod {
    [self playNote:[NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithFloat:dur],  [NSNumber numberWithInt:kDurationArg],
                    [NSNumber numberWithFloat:freq], [NSNumber numberWithInt:kFrequencyArg],
                    [NSNumber numberWithFloat:mod],  [NSNumber numberWithInt:kModulationArg],nil]];
}

                    
@end
