//
//  OscillatorInstrument.m
//  AKiPad
//
//  Created by Aurelius Prochazka on 8/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OscillatorInstrument.h"

@implementation OscillatorInstrument

- (instancetype)init {
    self = [super init];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
        
        _frequency = [[AKInstrumentProperty alloc] initWithValue:kFrequencyInit
                                                     minimumValue:kFrequencyMin
                                                     maximumValue:kFrequencyMax];
        [self addProperty:_frequency];
        
        _amplitude = [[AKInstrumentProperty alloc] initWithValue:kAmplitudeInit
                                                     minimumValue:kAmplitudeMin
                                                     maximumValue:kAmplitudeMax];
        [self addProperty:_amplitude];
        
        // INSTRUMENT DEFINITION ===============================================
        
        AKArray *partialStrengthArray = akpna(@1, @0.5, @1, nil);
        //[AKArray arrayFromConstants: akp(1),akp(0.5), akp(1), nil];
        
        AKSineTable *sine;
        sine = [[AKSineTable alloc] initWithSize:4096
                                 partialStrengths:partialStrengthArray];
        [self addFTable:sine];
        
        AKOscillator *myOscil;
        myOscil = [[AKOscillator alloc] initWithFTable:sine
                                              frequency:_frequency
                                              amplitude:_amplitude];
        [self connect:myOscil];
        
        
        
        // AUDIO OUTPUT ========================================================
        
        AKAudioOutput *audio;
        audio = [[AKAudioOutput alloc] initWithAudioSource:myOscil];
        [self connect:audio];
    }
    return self;
}


@end
