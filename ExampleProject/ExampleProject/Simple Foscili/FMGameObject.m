//
//  FMGameObject.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "FMGameObject.h"
#import "OCSSineTable.h"
#import "OCSFoscili.h"
#import "OCSOutputStereo.h"

@implementation FMGameObject

@synthesize frequency;
@synthesize modulation;

- (id)init {
    self = [super init];
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
        
        OCSFoscili *myFMOscillator = [[OCSFoscili alloc] initWithAmplitude:ocsp(0.4)
                                                                  Frequency:[frequency output]
                                                                    Carrier:ocsp(1)
                                                                 Modulation:[modulation output]
                                                                   ModIndex:ocsp(15)
                                                              FunctionTable:sineTable
                                                           AndOptionalPhase:nil];
        [self addOpcode:myFMOscillator];
        
        // AUDIO OUTPUT ========================================================
        
        OCSOutputStereo *monoOutput = [[OCSOutputStereo alloc] initWithMonoInput:[myFMOscillator output]];
        [self addOpcode:monoOutput];
    }
    return self;
}

- (void)playNoteForDuration:(float)dur 
                  Frequency:(float)freq 
                 Modulation:(float)mod {
    frequency.value = freq;
    modulation.value = mod;
    [self playNoteForDuration:dur];
}

                    
@end
