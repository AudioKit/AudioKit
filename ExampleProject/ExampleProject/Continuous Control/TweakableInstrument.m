//
//  TweakableInstrument.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "TweakableInstrument.h"
#import "CSDAssignment.h"

@implementation TweakableInstrument
//@synthesize myPropertyManager;
@synthesize amplitude;
@synthesize frequency;
@synthesize modulation;
@synthesize modIndex;

-(id)initWithOrchestra:(CSDOrchestra *)newOrchestra
{
    self = [super initWithOrchestra:newOrchestra];
    if (self) {
        amplitude  = [[CSDProperty alloc] initWithValue:0.1f Min:0.0f  Max:1.0f  isControlRate:YES];
        frequency  = [[CSDProperty alloc] initWithValue:440  Min:0     Max:22000 isControlRate:YES];
        modulation = [[CSDProperty alloc] initWithValue:0.5f Min:0.25f Max:2.2f  isControlRate:YES];
        modIndex   = [[CSDProperty alloc] initWithValue:1.0f Min:0.0f  Max:25.0f isControlRate:YES];
        
        //[self addProperties:amplitude, frequency, modulation, modIndex, nil];
        [self addProperty:amplitude];
        [self addProperty:frequency];
        [self addProperty:modulation];
        [self addProperty:modIndex];
        
        CSDSineTable *sineTable = [[CSDSineTable alloc] init];
        [self addFunctionTable:sineTable];
        
        //[myPropertyManager = [[CSDPropertyManager alloc] init];
        //[myPropertyManager addProperty:amplitude            forControllerNumber:12];
        //[myPropertyManager addProperty:modulationContinuous forControllerNumber:13];
        //[myPropertyManager addProperty:modIndexContinuous   forControllerNumber:14];
        
        CSDFoscili *myFoscili = 
        [[CSDFoscili alloc] initFMOscillatorWithAmplitude:[CSDParam paramWithProperty:amplitude]
                                                Frequency:[CSDParam paramWithProperty:frequency] 
                                                  Carrier:[CSDParamConstant paramWithInt:1] 
                                               Modulation:[CSDParamControl paramWithProperty:modulation]
                                                 ModIndex:[CSDParamControl paramWithProperty:modIndex]
                                            FunctionTable:sineTable 
                                         AndOptionalPhase:nil];
        [self addOpcode:myFoscili];
        
        CSDOutputStereo *stereoOutput = [[CSDOutputStereo alloc] initWithInputLeft:[myFoscili output] InputRight:[myFoscili output]];
        [self addOpcode:stereoOutput];
    }
    return self;
}

-(void) playNoteForDuration:(float)dur Frequency:(float)freq {
    frequency.value = freq;
    [self playNoteWithDuration:dur];
}


@end
