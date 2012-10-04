//
//  FMOscillatorInstrument.m
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 9/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "FMOscillatorInstrument.h"
#import "OCSSineTable.h"
#import "OCSFMOscillator.h"
#import "OCSAudio.h"

@implementation FMOscillatorInstrument

@synthesize frequency = freq;
@synthesize amplitude = amp;
@synthesize carrierMultiplier = car;
@synthesize modulatingMultiplier = mod;
@synthesize modulationIndex = index;

- (id)init {
    self = [super init];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
        freq = [[OCSInstrumentProperty alloc] initWithValue:kFrequencyInit
                                                   minValue:kFrequencyMin
                                                   maxValue:kFrequencyMax];
        [freq setControl:[OCSControl parameterWithString:@"Frequency"]];
        [self addProperty:freq];
        
        amp = [[OCSInstrumentProperty alloc] initWithValue:kAmplitudeInit
                                                  minValue:kAmplitudeMin
                                                  maxValue:kAmplitudeMax];
        [amp setControl:[OCSControl parameterWithString:@"Amplitude"]];
        [self addProperty:amp];
        
        car = [[OCSInstrumentProperty alloc] initWithValue:kCarrierMultiplierInit
                                                  minValue:kCarrierMultiplierMin
                                                  maxValue:kCarrierMultiplierMax];
        [car setControl:[OCSControl parameterWithString:@"CarrierMultiplier"]];
        [self addProperty:car];
        
        mod = [[OCSInstrumentProperty alloc] initWithValue:kModulatingMultiplierInit
                                                  minValue:kModulatingMultiplierMin
                                                  maxValue:kModulatingMultiplierMax];
        [mod setControl:[OCSControl parameterWithString:@"ModulatingMultiplier"]];
        [self addProperty:mod];
        
        index = [[OCSInstrumentProperty alloc] initWithValue:kModulationIndexInit
                                                    minValue:kModulationIndexMin
                                                    maxValue:kModulationIndexMax];
        [index setControl:[OCSControl parameterWithString:@"ModulationIndex"]];
        [self addProperty:index];
        
        // INSTRUMENT DEFINITION ===============================================
            
        OCSSineTable *sine = [[OCSSineTable alloc] init];
        [self addFTable:sine];

        OCSFMOscillator *fmOscillator;
        fmOscillator = [[OCSFMOscillator alloc] initWithFTable:sine
                                                 baseFrequency:[freq control]
                                             carrierMultiplier:[car control]
                                          modulatingMultiplier:[mod control]
                                               modulationIndex:[index control]
                                                     amplitude:[amp control]];
        [self connect:fmOscillator];


        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio = [[OCSAudio alloc] initWithMonoInput:[fmOscillator output]];
        [self connect:audio];
    }
    return self;
}


                    
@end
