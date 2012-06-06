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
@synthesize orchestra;

-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra {
    self = [super init];
    if (self) {
        //add to orchestra
        //now orchestra has access to run this instrument as text
        orchestra = newOrchestra;
        instrumentTagInOrchestra = [orchestra addInstrument:self];
        
        //define opcodes with properties connected to gameBehavior
    
        //H4Y - ARB: uses argument to set output
        CSDFunctionStatement *f = [[CSDFunctionStatement alloc] 
                                   initWithOutput:@"iSine" 
                                   TableSize:4096 
                                   GenRouting:10 
                                   AndParameters:nil];
        [self addFunctionStatement:f];
        
        //H4Y - ARB: This assumes that CSDFunctionStatement is ftgentmp
        //  and will look for [CSDFunctionStatement output] during csd conversion
        myFoscilOpcode = [[CSDFoscili alloc] 
                          initFMOscillatorWithAmplitude:[CSDParam initWithFloat:0.4]
                          kPitch:[CSDParam initWithPValue:kPValuePitchTag]
                          kCarrier:[CSDParam initWithInt:1]
                          xModulation:[CSDParam initWithPValue:kPValueModulationTag]
                          kModIndex:[CSDParam initWithInt:15]
                          FunctionTable:f
                          AndOptionalPhase:nil];
        [myFoscilOpcode setOutput:FINAL_OUTPUT];
        
        [self addOpcode:myFoscilOpcode];
    }
    return self;
}

-(NSString *) textForOrchestra {
    NSString * text=  @"iSine ftgentmp 0, 0, 4096, 10, 1\n"
    "aOut1 oscil 0.4, p4, iSine\n"
    "out aOut1";
    return text;
}

-(void) playNoteForDuration:(float)iDuration withFrequency:(float)iFreq {
    NSString * note = [NSString stringWithFormat:@"%0.2f %0.2f", iDuration, iFreq];
    [[CSDManager sharedCSDManager] playNote:note OnInstrument:instrumentTagInOrchestra];
}
                    
@end
