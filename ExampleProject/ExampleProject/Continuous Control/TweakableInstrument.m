//
//  TweakableInstrument.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "TweakableInstrument.h"
#import "OCSSineTable.h"
#import "OCSFoscili.h"
#import "OCSOutputStereo.h"
#import "OCSAssignment.h"

@implementation TweakableInstrument
@synthesize amplitude;
@synthesize frequency;
@synthesize modulation;
@synthesize modIndex;
//@synthesize myPropertyManager;
- (id)init
{
    self = [super init];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
    
        amplitude  = [[OCSProperty alloc] initWithValue:0.1f Min:0.0f  Max:1.0f];
        frequency  = [[OCSProperty alloc] init];
        modulation = [[OCSProperty alloc] initWithValue:0.5f Min:0.25f Max:2.2f];
        modIndex   = [[OCSProperty alloc] initWithValue:1.0f Min:0.0f  Max:25.0f];
        
        [amplitude  setControl:[OCSParamControl paramWithString:@"Amplitude"]]; 
        [frequency  setControl:[OCSParamControl paramWithString:@"Frequency"]]; 
        [modulation setControl:[OCSParamControl paramWithString:@"Modulation"]]; 
        [modIndex   setControl:[OCSParamControl paramWithString:@"ModIndex"]]; 
        
        [self addProperty:amplitude];
        [self addProperty:frequency];
        [self addProperty:modulation];
        [self addProperty:modIndex];
        
        //[myPropertyManager = [[OCSPropertyManager alloc] init];
        //[myPropertyManager addProperty:amplitude  forControllerNumber:12];
        //[myPropertyManager addProperty:modulation forControllerNumber:13];
        //[myPropertyManager addProperty:modIndex   forControllerNumber:14];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSSineTable *sineTable = [[OCSSineTable alloc] init];
        [self addFunctionTable:sineTable];
        
        OCSFoscili *myFMOscillator = 
        [[OCSFoscili alloc] initWithAmplitude:[amplitude control]
                                    Frequency:[frequency control]
                                      Carrier:ocsp(1)
                                   Modulation:[modulation control]
                                     ModIndex:[modIndex   control]
                                FunctionTable:sineTable 
                             AndOptionalPhase:nil];
        [self addOpcode:myFMOscillator];
        
        // AUDIO OUTPUT ========================================================
        
        OCSOutputStereo *stereoOutput = 
        [[OCSOutputStereo alloc] initWithMonoInput:[myFMOscillator output]];
        [self addOpcode:stereoOutput];
        
        /*
        // Test to show amplitude slider moving also
        [self addString:[NSString stringWithFormat:@"%@ = %@ + 0.001\n", amplitude, amplitude]];
         */
    }
    return self;
}

- (void)playNoteForDuration:(float)dur Frequency:(float)freq {
    frequency.value = freq;
    [self playNoteForDuration:dur];
}


@end
