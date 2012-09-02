//
//  SimpleFMOscillator.m
//  OCSiPad
//
//  Created by Aurelius Prochazka on 9/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "SimpleFMOscillator.h"
#import "OCSSineTable.h"
#import "OCSFMOscillator.h"
#import "OCSAudio.h"

@interface SimpleFMOscillator () {
    OCSEventProperty *freq;
    OCSInstrumentProperty *mod;
}
@end

@implementation SimpleFMOscillator

@synthesize frequency = freq;
@synthesize modulation = mod;

- (id)init {
    self = [super init];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
        freq = [[OCSEventProperty alloc] initWithValue:220 minValue:kFrequencyMin maxValue:kFrequencyMax];
        mod  = [[OCSInstrumentProperty alloc] initWithValue:1.0 minValue:kModulationMin maxValue:kModulationMax];
        
        [freq setControl:[OCSControl parameterWithString:@"Frequency"]];
        [mod  setControl:[OCSControl parameterWithString:@"Modulation"]];
        
        [self addEventProperty:freq];
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
        [self connect:fmOscillator];
        
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio = [[OCSAudio alloc] initWithLeftInput:[fmOscillator output]
                                                   rightInput:[fmOscillator output]];
        [self connect:audio];
    }
    return self;
}



@end