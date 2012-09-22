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
    SeqInstrumentNote *note = [[SeqInstrumentNote alloc] init];
    note.instrument = self;
    return note;
}

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

@synthesize frequency = freq;

- (id)init {
    self = [super init];
    if (self) {
        NSString *freqString = @"Frequency";
        freq = [[OCSNoteProperty alloc] initWithValue:kFrequencyInit
                                             minValue:kFrequencyMin
                                             maxValue:kFrequencyMax];
        [freq setControl:[OCSControl parameterWithString:freqString]];
        [self.properties setValue:freq forKey:freqString];
    }
    return self;
}




@end