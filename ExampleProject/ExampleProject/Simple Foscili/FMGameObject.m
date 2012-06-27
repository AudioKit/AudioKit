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

@interface FMGameObject () {
    OCSProperty *amplitude;
    OCSProperty *frequency;
    OCSProperty *modulation;
}
@end

@implementation FMGameObject

- (id)init {
    self = [super init];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
        frequency  = [[OCSProperty alloc] init];
        modulation = [[OCSProperty alloc] init];

        [frequency  setControl:[OCSParamControl paramWithString:@"Frequency"]]; 
        [modulation setControl:[OCSParamControl paramWithString:@"Modulation"]]; 
        
        [self addProperty:frequency];
        [self addProperty:modulation];
        
        // INSTRUMENT DEFINITION ===============================================
            
        OCSSineTable *sineTable = [[OCSSineTable alloc] init];
        [self addFunctionTable:sineTable];
        OCSFoscili *myFMOscillator = [[OCSFoscili alloc] initWithAmplitude:ocsp(0.4)
                                                             BaseFrequency:[frequency control]
                                                         CarrierMultiplier:ocsp(1) 
                                                      ModulatingMultiplier:[modulation control]
                                                           ModulationIndex:ocsp(15)
                                                             FunctionTable:sineTable];
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
    NSLog(@"Playing note at frequency = %0.2f and modulation = %0.2f", freq, mod);
    [self playNoteForDuration:dur];
}

                    
@end
