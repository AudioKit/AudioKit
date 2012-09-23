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
        [mod  setControl:[OCSControl parameterWithString:@"Modulation"]];
        [self addProperty:mod];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSSineTable *sineTable = [[OCSSineTable alloc] init];
        [self addFTable:sineTable];
        
        OCSFMOscillator *fmOscillator;
        fmOscillator = [[OCSFMOscillator alloc] initWithAmplitude:ocsp(0.2)
                                                    baseFrequency:[note.frequency control]
                                                carrierMultiplier:ocsp(2)
                                             modulatingMultiplier:[mod control]
                                                  modulationIndex:ocsp(15)
                                                           fTable:sineTable];
        [self connect:fmOscillator];
        
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio = [[OCSAudio alloc] initWithLeftInput:[fmOscillator output]
                                                   rightInput:[fmOscillator output]];
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
        NSString *frequencyString = @"Frequency";
        frequency = [[OCSNoteProperty alloc] initWithNote:self
                                             initialValue:kFrequencyInit
                                                 minValue:kFrequencyMin
                                                 maxValue:kFrequencyMax];
        [frequency setControl:[OCSControl parameterWithString:frequencyString]];
        [self.properties setValue:frequency forKey:frequencyString];
    }
    return self;
}




@end