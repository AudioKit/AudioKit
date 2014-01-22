//
//  FMOscillatorInstrument.m
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 9/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "FMOscillatorInstrument.h"

@implementation FMOscillatorInstrument

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
        
        _carrierMultiplier = [[AKInstrumentProperty alloc] initWithValue:kCarrierMultiplierInit
                                                             minimumValue:kCarrierMultiplierMin
                                                             maximumValue:kCarrierMultiplierMax];
        [self addProperty:_carrierMultiplier];
        
        _modulatingMultiplier = [[AKInstrumentProperty alloc] initWithValue:kModulatingMultiplierInit
                                                                minimumValue:kModulatingMultiplierMin
                                                                maximumValue:kModulatingMultiplierMax];
        [self addProperty:_modulatingMultiplier];
        
        _modulationIndex = [[AKInstrumentProperty alloc] initWithValue:kModulationIndexInit
                                                           minimumValue:kModulationIndexMin
                                                           maximumValue:kModulationIndexMax];
        [self addProperty:_modulationIndex];
        
        // INSTRUMENT DEFINITION ===============================================
        
        AKSineTable *sine = [[AKSineTable alloc] init];
        [self addFTable:sine];
        
        AKFMOscillator *fmOscillator;
        fmOscillator = [[AKFMOscillator alloc] initWithFTable:sine
                                                 baseFrequency:_frequency
                                             carrierMultiplier:_carrierMultiplier
                                          modulatingMultiplier:_modulatingMultiplier
                                               modulationIndex:_modulationIndex
                                                     amplitude:_amplitude];
        [self connect:fmOscillator];
        
        
        // AUDIO OUTPUT ========================================================
        
        AKAudioOutput *audio = [[AKAudioOutput alloc] initWithAudioSource:fmOscillator];
        [self connect:audio];
    }
    return self;
}



@end
