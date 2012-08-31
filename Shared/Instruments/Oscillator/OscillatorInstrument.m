//
//  OscillatorInstrument.m
//  OCSiPad
//
//  Created by Aurelius Prochazka on 8/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OscillatorInstrument.h"

#import "OCSSineTable.h"
#import "OCSOscillator.h"
#import "OCSAudio.h"

@implementation OscillatorInstrument 

@synthesize frequency = _frequency;
@synthesize amplitude = _amplitude;

- (id)init {
    self = [super init];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
        
        _frequency = [[OCSInstrumentProperty alloc] initWithValue:kFrequencyInit
                                                         minValue:kFrequencyMin
                                                         maxValue:kFrequencyMax];
        [_frequency setControl:[OCSControl parameterWithString:@"Frequency"]];
        [self addProperty:_frequency];
        
        _amplitude = [[OCSInstrumentProperty alloc] initWithValue:kAmplitudeInit
                                                         minValue:kAmplitudeMin
                                                         maxValue:kAmplitudeMax];
        [_amplitude setControl:[OCSControl parameterWithString:@"Amplitude"]];
        [self addProperty:_amplitude];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSParameterArray *partialStrengthParamArray =
        [OCSParameterArray paramArrayFromParams: ocsp(1),ocsp(0.5), ocsp(1), nil];
        
        OCSSineTable *sine;
        sine = [[OCSSineTable alloc] initWithSize:4096
                                 partialStrengths:partialStrengthParamArray];
        [self addFTable:sine];
        
        OCSOscillator *myOscil;
        myOscil = [[OCSOscillator alloc] initWithFTable:sine
                                              frequency:[_frequency control]
                                              amplitude:[_amplitude control]
                                                  phase:ocsp(0)];
        [self connect:myOscil];
        

        
        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio;
        audio = [[OCSAudio alloc] initWithMonoInput:[myOscil output]];
        [self connect:audio];
    }
    return self;
}


@end
