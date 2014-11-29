//
//  FMOscillator.m
//  TouchRegions
//
//  Created by Aurelius Prochazka on 8/7/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
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

        [self addProperty:_frequency];
        [self addProperty:_carrierMultiplier];
        [self addProperty:_modulatingMultiplier];
        [self addProperty:_modulationIndex];
        
        // INSTRUMENT DEFINITION ===============================================
        
        AKSineTable *sineTable = [[AKSineTable alloc] init];
        [self addFTable:sineTable];
        
        AKFMOscillator *fmOscillator;
        fmOscillator = [[AKFMOscillator alloc] initWithFTable:sineTable
                                                baseFrequency:_frequency
                                            carrierMultiplier:_carrierMultiplier
                                         modulatingMultiplier:_modulatingMultiplier
                                              modulationIndex:_modulationIndex
                                                    amplitude:akp(0.2)
                                                        phase:akp(0)];
        [self connect:fmOscillator];
        
        // AUDIO OUTPUT ========================================================
        
        AKAudioOutput *audio = [[AKAudioOutput alloc] initWithAudioSource:fmOscillator];
        [self connect:audio];
    }
    return self;
}

@end
