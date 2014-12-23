//
//  TweakableInstrument.m
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/30/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "TweakableInstrument.h"

@implementation TweakableInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
        
        _amplitude  = [[AKInstrumentProperty alloc] initWithValue:0.1
                                                          minimum:0.0
                                                          maximum:0.3];
        
        _frequency  = [[AKInstrumentProperty alloc] initWithValue:220
                                                          minimum:110
                                                          maximum:880];
        
        _modulation = [[AKInstrumentProperty alloc] initWithValue:0.5
                                                          minimum:0.25
                                                          maximum:2.2];
        
        _modIndex   = [[AKInstrumentProperty alloc] initWithValue:1.0
                                                          minimum:0.0
                                                          maximum:25];
        
        [self addProperty:_amplitude];
        [self addProperty:_frequency];
        [self addProperty:_modulation];
        [self addProperty:_modIndex];
        
        // INSTRUMENT DEFINITION ===============================================
        
        AKSineTable *sineTable = [[AKSineTable alloc] init];
        [self addFTable:sineTable];
        
        AKFMOscillator *fmOscil;
        fmOscil = [[AKFMOscillator alloc] initWithFTable:sineTable
                                           baseFrequency:_frequency
                                       carrierMultiplier:akp(1)
                                    modulatingMultiplier:_modulation
                                         modulationIndex:_modIndex
                                               amplitude:_amplitude
                                                   phase:akp(0)];
        [self connect:fmOscil];
        
        // AUDIO OUTPUT ========================================================
        
        AKAudioOutput *audio = [[AKAudioOutput alloc] initWithAudioSource:fmOscil];
        [self connect:audio];
        
    }
    return self;
}

@end
