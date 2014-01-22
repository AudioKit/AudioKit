//
//  MarimbaInstrument.m
//  AudioKit
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
//        frequency = [[AKInstrumentProperty alloc] initWithValue:kFrequencyInit
//                                                        minimumValue:kFrequencyMin
//                                                        maximumValue:kFrequencyMax];
//        [self addProperty:frequency];
//        
//        ampliude = [[AKInstrumentProperty alloc] initWithValue:kAmplitudeInit
//                                                       minimumValue:kAmplitudeMin
//                                                       maximumValue:kAmplitudeMax];
//        [self addProperty:amplitude];
//        
//        vibratoFrequency = [[AKInstrumentProperty alloc] initWithValue:kFrequencyInit
//                                                               minimumValue:kFrequencyMin
//                                                               maximumValue:kFrequencyMax];
//        [self addProperty:vibratoFrequency];
//        
//        vibratoAmpliude = [[AKInstrumentProperty alloc] initWithValue:kAmplitudeInit
//                                                              minimumValue:kAmplitudeMin
//                                                              maximumValue:kAmplitudeMax];
//        [self addProperty:vibratoAmpliude];
//        
//        // INSTRUMENT DEFINITION ===============================================
//        
//        AKArray *partialStrengthArray = akpna(@1, @0.5, @1, nil);
//        
//        AKSineTable *sine;
//        sine = [[AKSineTable alloc] initWithSize:4096
//                                 partialStrengths:partialStrengthArray];
//        [self addFTable:sine];
//        
//        AKMarimba  *marimba;
//        marimba = [[AKMarimba alloc] initWithHardness:hardness
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
//        AKAudioOutput *audio;
//        audio = [[AKAudioOutput alloc] initWithMonoInput:marimba];
//        [self connect:audio];
    }
    return self;
}


@end


@implementation MarimbaNote

                   
@end