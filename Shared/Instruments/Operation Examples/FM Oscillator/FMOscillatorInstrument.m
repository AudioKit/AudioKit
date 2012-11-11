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
#import "OCSAudioOutput.h"

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
        [self addProperty:freq];
        
        amp = [[OCSInstrumentProperty alloc] initWithValue:kAmplitudeInit
                                                  minValue:kAmplitudeMin
                                                  maxValue:kAmplitudeMax];
        [self addProperty:amp];
        
        car = [[OCSInstrumentProperty alloc] initWithValue:kCarrierMultiplierInit
                                                  minValue:kCarrierMultiplierMin
                                                  maxValue:kCarrierMultiplierMax];
        [self addProperty:car];
        
        mod = [[OCSInstrumentProperty alloc] initWithValue:kModulatingMultiplierInit
                                                  minValue:kModulatingMultiplierMin
                                                  maxValue:kModulatingMultiplierMax];
        [self addProperty:mod];
        
        index = [[OCSInstrumentProperty alloc] initWithValue:kModulationIndexInit
                                                    minValue:kModulationIndexMin
                                                    maxValue:kModulationIndexMax];
        [self addProperty:index];
        
        // INSTRUMENT DEFINITION ===============================================
            
        OCSSineTable *sine = [[OCSSineTable alloc] init];
        [self addFTable:sine];

        OCSFMOscillator *fmOscillator;
        fmOscillator = [[OCSFMOscillator alloc] initWithFTable:sine
                                                 baseFrequency:freq
                                             carrierMultiplier:car
                                          modulatingMultiplier:mod
                                               modulationIndex:index
                                                     amplitude:amp];
        [self connect:fmOscillator];


        // AUDIO OUTPUT ========================================================
        
        OCSAudioOutput *audio = [[OCSAudioOutput alloc] initWithAudioSource:fmOscillator];
        [self connect:audio];
    }
    return self;
}


                    
@end
