//
//  FMOscillator.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "FMGameObject.h"
#import "FMGameObjectConstants.h"

@implementation FMGameObject

-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra {
    self = [super initWithOrchestra:newOrchestra];
    if (self) {
        //define opcodes with properties connected to gameBehavior
    
        //H4Y - ARB: uses argument to set output
        CSDSineTable *sineTable = [[CSDSineTable alloc] initDefaultsWithOutput:@"iSine"];
        [self addFunctionTable:sineTable];
        
        //H4Y - ARB: This assumes that CSDFunctionTable is ftgentmp
        //  and will look for [CSDFunctionTable output] during csd conversion
        myFoscilOpcode = [[CSDFoscili alloc] initFMOscillatorWithAmplitude:[CSDParamConstant paramWithFloat:0.4]
                                                                    kPitch:[CSDParamConstant paramWithPValue:kPValuePitchTag]
                                                                  kCarrier:[CSDParamConstant paramWithInt:1]
                                                               xModulation:[CSDParamConstant paramWithPValue:kPValueModulationTag]
                                                                 kModIndex:[CSDParamConstant paramWithInt:15]
                                                             FunctionTable:sineTable
                                                          AndOptionalPhase:nil];
        [self addOpcode:myFoscilOpcode];
        CSDOutputMono * monoOutput = [[CSDOutputMono alloc] initWithInput:[myFoscilOpcode output]]; 
        [self addOpcode:monoOutput];
    }
    return self;
}

-(void) playNoteForDuration:(float)dur Pitch:(float)pitch Modulation:(float)modulation {
    int instrumentNumber = [[orchestra instruments] indexOfObject:self] + 1;
    NSString * note = [NSString stringWithFormat:@"%0.2f %0.2f %0.2f", dur, pitch, modulation];
    [[CSDManager sharedCSDManager] playNote:note OnInstrument:instrumentNumber];
}

                    
@end
