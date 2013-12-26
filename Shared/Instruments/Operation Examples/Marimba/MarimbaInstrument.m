//
//  MarimbaInstrument.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/29/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "MarimbaInstrument.h"

@implementation MarimbaInstrument

- (instancetype)init {
    self = [super init];
    
    if (self) {
//        
//        // INPUTS AND CONTROLS =================================================
//        
//        frequency = [[OCSInstrumentProperty alloc] initWithValue:kFrequencyInit
//                                                        minValue:kFrequencyMin
//                                                        maxValue:kFrequencyMax];
//        [self addProperty:frequency];
//        
//        ampliude = [[OCSInstrumentProperty alloc] initWithValue:kAmplitudeInit
//                                                       minValue:kAmplitudeMin
//                                                       maxValue:kAmplitudeMax];
//        [self addProperty:amplitude];
//        
//        vibratoFrequency = [[OCSInstrumentProperty alloc] initWithValue:kFrequencyInit
//                                                               minValue:kFrequencyMin
//                                                               maxValue:kFrequencyMax];
//        [self addProperty:vibratoFrequency];
//        
//        vibratoAmpliude = [[OCSInstrumentProperty alloc] initWithValue:kAmplitudeInit
//                                                              minValue:kAmplitudeMin
//                                                              maxValue:kAmplitudeMax];
//        [self addProperty:vibratoAmpliude];
//        
//        // INSTRUMENT DEFINITION ===============================================
//        
//        OCSArray *partialStrengthArray = ocspna(@1, @0.5, @1, nil);
//        
//        OCSSineTable *sine;
//        sine = [[OCSSineTable alloc] initWithSize:4096
//                                 partialStrengths:partialStrengthArray];
//        [self addFTable:sine];
//        
//        OCSMarimba  *marimba;
//        marimba = [[OCSMarimba alloc] initWithHardness:hardness
//                                              position:position
//                                             decayTime:decayTime
//                                    strikeImpulseTable:sine
//                                     vibratoShapeTable:sine
//                                             frequency:frequency
//                                             amplitude:amplitude
//                                      vibratoFrequency:vibratoFrequency
//                                      vibratoAmplitude:vibratoAmplitude];
//
//        [self connect:marimba];
//
//        // AUDIO OUTPUT ========================================================
//        
//        OCSAudioOutput *audio;
//        audio = [[OCSAudioOutput alloc] initWithMonoInput:marimba];
//        [self connect:audio];
    }
    return self;
}


@end


@implementation MarimbaNote

                   
@end