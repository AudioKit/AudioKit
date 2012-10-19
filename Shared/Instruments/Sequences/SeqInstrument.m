//
//  SeqInstrument.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 9/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "SeqInstrument.h"

#import "OCSSineTable.h"
#import "OCSFMOscillator.h"
#import "OCSAudioOutput.h"

@implementation SeqInstrument

@synthesize modulation = mod;

- (id)init {
    self = [super init];
    if (self) {
        // NOTE BASED CONTROL ==================================================
        SeqInstrumentNote *note = [[SeqInstrumentNote alloc] init];
        [self addNoteProperty:note.frequency];
        
        // INSTRUMENT CONTROL ==================================================
        mod  = [[OCSInstrumentProperty alloc] initWithValue:kModulationInit
                                                   minValue:kModulationMin
                                                   maxValue:kModulationMax];
        [self addProperty:mod];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSSineTable *sineTable = [[OCSSineTable alloc] init];
        [self addFTable:sineTable];
        
        OCSFMOscillator *fmOscillator;
        fmOscillator = [[OCSFMOscillator alloc] initWithFTable:sineTable
                                                 baseFrequency:note.frequency
                                             carrierMultiplier:ocsp(2)
                                          modulatingMultiplier:mod
                                               modulationIndex:ocsp(15)
                                                     amplitude:ocsp(0.2)];
        [self connect:fmOscillator];
        
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudioOutput *audio = [[OCSAudioOutput alloc] initWithMonoInput:fmOscillator];
        [self connect:audio];
    }
    return self;
}

@end

@implementation SeqInstrumentNote

@synthesize frequency=_frequency;

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
        self.frequency.value = frequency;
    }
    return self;
}



@end