//
//  FMOscillatorInstrument.m
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 9/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "FMOscillatorInstrument.h"

@implementation FMOscillatorInstrument

- (id)init {
    self = [super init];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
        _frequency = [[OCSInstrumentProperty alloc] initWithValue:kFrequencyInit
                                                         minValue:kFrequencyMin
                                                         maxValue:kFrequencyMax];
        [self addProperty:_frequency];
        
        _amplitude = [[OCSInstrumentProperty alloc] initWithValue:kAmplitudeInit
                                                         minValue:kAmplitudeMin
                                                         maxValue:kAmplitudeMax];
        [self addProperty:_amplitude];
        
        _carrierMultiplier = [[OCSInstrumentProperty alloc] initWithValue:kCarrierMultiplierInit
                                                                 minValue:kCarrierMultiplierMin
                                                                 maxValue:kCarrierMultiplierMax];
        [self addProperty:_carrierMultiplier];
        
        _modulatingMultiplier = [[OCSInstrumentProperty alloc] initWithValue:kModulatingMultiplierInit
                                                                    minValue:kModulatingMultiplierMin
                                                                    maxValue:kModulatingMultiplierMax];
        [self addProperty:_modulatingMultiplier];
        
        _modulationIndex = [[OCSInstrumentProperty alloc] initWithValue:kModulationIndexInit
                                                               minValue:kModulationIndexMin
                                                               maxValue:kModulationIndexMax];
        [self addProperty:_modulationIndex];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSSineTable *sine = [[OCSSineTable alloc] init];
        [self addFTable:sine];
        
        OCSFMOscillator *fmOscillator;
        fmOscillator = [[OCSFMOscillator alloc] initWithFTable:sine
                                                 baseFrequency:_frequency
                                             carrierMultiplier:_carrierMultiplier
                                          modulatingMultiplier:_modulatingMultiplier
                                               modulationIndex:_modulationIndex
                                                     amplitude:_amplitude];
        [self connect:fmOscillator];
        
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudioOutput *audio = [[OCSAudioOutput alloc] initWithAudioSource:fmOscillator];
        [self connect:audio];
    }
    return self;
}



@end
