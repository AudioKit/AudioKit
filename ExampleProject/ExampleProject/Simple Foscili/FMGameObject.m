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
#import "OCSAudio.h"

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
        
        
        // Method 1 for defining an opcode
        
        OCSFoscili *fmOscillator;
        fmOscillator = [[OCSFoscili alloc] initWithAmplitude:ocsp(0.4)
                                               BaseFrequency:[frequency control]
                                           CarrierMultiplier:ocsp(2) 
                                        ModulatingMultiplier:[modulation control]
                                             ModulationIndex:ocsp(15)
                                               FunctionTable:sineTable];
        [self addOpcode:fmOscillator];
        
        // Method 2 for defining an opcode - What do you think ARB? - AOP
         
        OCSFoscili *fmOscillator2 = [[OCSFoscili alloc] init];
        [fmOscillator2 setAmplitude:ocsp(0.4)];
        [fmOscillator2 setBaseFrequency:[frequency control]];
        [fmOscillator2 setCarrierMultiplier:ocsp(3)];
        [fmOscillator2 setModulatingMultiplier:[modulation control]]; 
        [fmOscillator2 setModulationIndex:ocsp(10)];
        [fmOscillator2 setFunctionTable:sineTable];
        [self addOpcode:fmOscillator2];

        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio = [[OCSAudio alloc] initWithLeftInput:[fmOscillator output]
                                                   RightInput:[fmOscillator2 output]];
        [self addOpcode:audio];
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
