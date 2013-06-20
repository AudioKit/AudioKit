//
//  SeqInstrument.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 9/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "SeqInstrument.h"

@implementation SeqInstrument

- (id)init {
    self = [super init];
    if (self) {
        // NOTE BASED CONTROL ==================================================
        SeqInstrumentNote *note = [[SeqInstrumentNote alloc] init];
        [self addNoteProperty:note.frequency];
        
        // INSTRUMENT CONTROL ==================================================
        _modulation  = [[OCSInstrumentProperty alloc] initWithValue:kModulationInit
                                                           minValue:kModulationMin
                                                           maxValue:kModulationMax];
        [self addProperty:_modulation];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSSineTable *sineTable = [[OCSSineTable alloc] init];
        [self addFTable:sineTable];
        
        OCSFMOscillator *fmOscillator;
        fmOscillator = [[OCSFMOscillator alloc] initWithFTable:sineTable
                                                 baseFrequency:note.frequency
                                             carrierMultiplier:ocsp(2)
                                          modulatingMultiplier:_modulation
                                               modulationIndex:ocsp(15)
                                                     amplitude:ocsp(0.2)];
        [self connect:fmOscillator];
        
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudioOutput *audio = [[OCSAudioOutput alloc] initWithAudioSource:fmOscillator];
        [self connect:audio];
    }
    return self;
}

@end

@implementation SeqInstrumentNote

- (id)init {
    self = [super init];
    if (self) {
        _frequency = [[OCSNoteProperty alloc] initWithValue:kFrequencyInit
                                                   minValue:kFrequencyMin
                                                   maxValue:kFrequencyMax];
        [self addProperty:_frequency];
    }
    return self;
}

- (id)initWithFrequency:(float)frequency {
    self = [self init];
    if (self) {
        _frequency.value = frequency;
    }
    return self;
}



@end