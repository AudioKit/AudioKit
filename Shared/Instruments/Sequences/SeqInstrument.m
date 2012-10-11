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
#import "OCSAudio.h"

@implementation SeqInstrument

@synthesize modulation = mod;

- (SeqInstrumentNote *)createNote {
    return [[SeqInstrumentNote alloc] initWithInstrument:self];
}

- (id)init {
    self = [super init];
    if (self) {
        // NOTE BASED CONTROL ==================================================
        SeqInstrumentNote *note = [self createNote];
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
                                                 baseFrequency:[note.frequency constant]
                                             carrierMultiplier:ocsp(2)
                                          modulatingMultiplier:mod
                                               modulationIndex:ocsp(15)
                                                     amplitude:ocsp(0.2)];
        [self connect:fmOscillator];
        
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio = [[OCSAudio alloc] initWithMonoInput:fmOscillator];
        [self connect:audio];
    }
    return self;
}

@end

@implementation SeqInstrumentNote

@synthesize frequency;

- (id)initWithInstrument:(OCSInstrument *)anInstrument {
    self = [super initWithInstrument:anInstrument];
    if (self) {
        frequency = [[OCSNoteProperty alloc] initWithNote:self
                                             initialValue:kFrequencyInit
                                                 minValue:kFrequencyMin
                                                 maxValue:kFrequencyMax];
        [self addProperty:frequency];
    }
    return self;
}




@end