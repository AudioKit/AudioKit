//
//  FMGameObject.m
//  Objective-Csound Example
//
//  Created by Adam Boulanger on 6/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "FMGameObject.h"
#import "OCSSineTable.h"
#import "OCSFMOscillator.h"
#import "OCSAudio.h"

@interface FMGameObject () {
    OCSProperty *amp;
    OCSProperty *freq;
    OCSProperty *mod;
}
@end

@implementation FMGameObject

@synthesize frequency = freq;
@synthesize modulation = mod;

- (id)init {
    self = [super init];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
        freq = [[OCSProperty alloc] initWithValue:220 minValue:kFrequencyMin  maxValue:kFrequencyMax];
        mod  = [[OCSProperty alloc] initWithValue:1.0 minValue:kModulationMin maxValue:kModulationMax];

        [freq setControl:[OCSControl parameterWithString:@"Frequency"]]; 
        [mod  setControl:[OCSControl parameterWithString:@"Modulation"]]; 
        
        [self addProperty:freq];
        [self addProperty:mod];
        
        // INSTRUMENT DEFINITION ===============================================
            
        OCSSineTable *sineTable = [[OCSSineTable alloc] init];
        [self addFTable:sineTable];

        OCSFMOscillator *fmOscillator;
        fmOscillator = [[OCSFMOscillator alloc] initWithAmplitude:ocsp(0.2)
                                                    baseFrequency:[freq control]
                                                carrierMultiplier:ocsp(2) 
                                             modulatingMultiplier:[mod control]
                                                  modulationIndex:ocsp(15)
                                                           fTable:sineTable];
        [self addOpcode:fmOscillator];


        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio = [[OCSAudio alloc] initWithLeftInput:[fmOscillator output]
                                                   rightInput:[fmOscillator output]];
        [self addOpcode:audio];
    }
    return self;
}

- (void)playNoteForDuration:(float)noteDuration 
                  Frequency:(float)noteFrequency
                 Modulation:(float)noteModulation;
{
    freq.value  = noteFrequency;
    mod.value = noteModulation;
    NSLog(@"Playing note at frequency = %0.2f and modulation = %0.2f", noteFrequency, noteModulation);
    [self playNoteForDuration:noteDuration];
}

                    
@end
