//
//  FMOscillator.m
//  TouchRegions
//
//  Created by Aurelius Prochazka on 8/7/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "FMOscillator.h"

@implementation FMOscillator

- (instancetype)init {
    self = [super init];
    if (self) {
        
        // INSTRUMENT CONTROL ==================================================
        _frequency            = [[AKInstrumentProperty alloc] initWithValue:440 minimum:1.0 maximum:880];
        _carrierMultiplier    = [[AKInstrumentProperty alloc] initWithValue:1.0 minimum:0.0 maximum:2.0];
        _modulatingMultiplier = [[AKInstrumentProperty alloc] initWithValue:1.0 minimum:0.0 maximum:2.0];
        _modulationIndex      = [[AKInstrumentProperty alloc] initWithValue:15  minimum:0   maximum:30];
        _amplitude            = [[AKInstrumentProperty alloc] initWithValue:0.0 minimum:0   maximum:0.2];
        
        [self addProperty:_frequency];
        [self addProperty:_carrierMultiplier];
        [self addProperty:_modulatingMultiplier];
        [self addProperty:_modulationIndex];
        [self addProperty:_amplitude];
        
        // INSTRUMENT DEFINITION ===============================================
        
        AKFMOscillator *fmOscillator;
        fmOscillator = [[AKFMOscillator alloc] initWithFunctionTable:[AKManager standardSineWave]
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
