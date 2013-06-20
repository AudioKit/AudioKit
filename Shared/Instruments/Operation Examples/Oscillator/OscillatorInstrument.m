//
//  OscillatorInstrument.m
//  OCSiPad
//
//  Created by Aurelius Prochazka on 8/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OscillatorInstrument.h"

@implementation OscillatorInstrument 

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
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSArray *partialStrengthArray = ocspna(@1, @0.5, @1, nil);
        //[OCSArray arrayFromConstants: ocsp(1),ocsp(0.5), ocsp(1), nil];
        
        OCSSineTable *sine;
        sine = [[OCSSineTable alloc] initWithSize:4096
                                 partialStrengths:partialStrengthArray];
        [self addFTable:sine];
        
        OCSOscillator *myOscil;
        myOscil = [[OCSOscillator alloc] initWithFTable:sine
                                              frequency:_frequency
                                              amplitude:_amplitude];
        [self connect:myOscil];
        

        
        // AUDIO OUTPUT ========================================================
        
        OCSAudioOutput *audio;
        audio = [[OCSAudioOutput alloc] initWithAudioSource:myOscil];
        [self connect:audio];
    }
    return self;
}


@end
