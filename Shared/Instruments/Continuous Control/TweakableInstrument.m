//
//  TweakableInstrument.m
//  Objective-C Sound Example
//
//  Created by Adam Boulanger on 6/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "TweakableInstrument.h"

@implementation TweakableInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
    
        _amplitude  = [[OCSInstrumentProperty alloc] initWithValue:kTweakableAmplitudeInit
                                                      minimumValue:kTweakableAmplitudeMin
                                                      maximumValue:kTweakableAmplitudeMax];
        _frequency  = [[OCSInstrumentProperty alloc] initWithValue:kTweakableFrequencyInit
                                                      minimumValue:kTweakableFrequencyMin
                                                      maximumValue:kTweakableFrequencyMax];
        _modulation = [[OCSInstrumentProperty alloc] initWithValue:kTweakableModulationInit
                                                      minimumValue:kTweakableModulationMin
                                                      maximumValue:kTweakableModulationMax];
        _modIndex   = [[OCSInstrumentProperty alloc] initWithValue:kTweakableModIndexInit
                                                      minimumValue:kTweakableModIndexMin
                                                      maximumValue:kTweakableModIndexMax];
                
        [self addProperty:_amplitude];
        [self addProperty:_frequency];
        [self addProperty:_modulation];
        [self addProperty:_modIndex];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSSineTable *sineTable = [[OCSSineTable alloc] init];
        [self addFTable:sineTable];
        
        OCSFMOscillator *fmOscil;
        fmOscil = [[OCSFMOscillator alloc] initWithFTable:sineTable
                                            baseFrequency:_frequency
                                        carrierMultiplier:ocsp(1)
                                     modulatingMultiplier:_modulation
                                          modulationIndex:_modIndex
                                                amplitude:_amplitude];
        [self connect:fmOscil];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudioOutput *audio = [[OCSAudioOutput alloc] initWithAudioSource:fmOscil];
        [self connect:audio];
        
        /*
        // Test to show amplitude slider moving also
        [self addString:[NSString stringWithFormat:
         @"%@ = %@ + 0.001\n", amplitude, amplitude]];
         */
    }
    return self;
}
@end
