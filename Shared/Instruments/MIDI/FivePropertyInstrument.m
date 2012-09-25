//
//  FivePropertyInstrument.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 8/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//


#import "FivePropertyInstrument.h"
#import "OCSSineTable.h"
#import "OCSProduct.h"
#import "OCSFMOscillator.h"
#import "OCSLowPassButterworthFilter.h"
#import "OCSAudio.h"

@implementation FivePropertyInstrument

@synthesize pitchBend, modulation, cutoffFrequency;

- (FivePropertyInstrumentNote *)createNote {
    return [[FivePropertyInstrumentNote alloc] initWithInstrument:self];
}

-(id)init
{
    self = [super init];
    if ( self) {
        
        // NOTE BASED CONTROL ==================================================
        FivePropertyInstrumentNote *note = [self createNote];
        [self addNoteProperty:note.volume];
        [self addNoteProperty:note.frequency];
        
        // INPUTS AND CONTROLS =================================================
        pitchBend = [[OCSInstrumentProperty alloc] initWithValue:1
                                                   minValue:kPitchBendMin
                                                   maxValue:kPitchBendMax];
        modulation = [[OCSInstrumentProperty alloc] initWithMinValue:kModulationMin
                                                     maxValue:kModulationMax];
        cutoffFrequency = [[OCSInstrumentProperty alloc] initWithMinValue:kLpCutoffMin
                                                        maxValue:kLpCutoffMax];
        
        [pitchBend       setControl:[OCSControl parameterWithString:@"PitchBend"]];
        [modulation      setControl:[OCSControl parameterWithString:@"Modulation"]];
        [cutoffFrequency setControl:[OCSControl parameterWithString:@"LowPassCutoff"]];
        
        [self addProperty:pitchBend];
        [self addProperty:modulation];
        [self addProperty:cutoffFrequency];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSSineTable *sine = [[OCSSineTable alloc] init];
        [self addFTable:sine];
        
        OCSControl *bentFreq;
        bentFreq = [[OCSControl alloc] initWithExpression:[NSString stringWithFormat:@"%@  * %@", note.frequency, pitchBend]];
        
        OCSFMOscillator *fm = [[OCSFMOscillator alloc] initWithAmplitude:[note.volume constant]
                                                           baseFrequency:bentFreq
                                                       carrierMultiplier:ocsp(2)
                                                    modulatingMultiplier:[modulation control]
                                                         modulationIndex:ocsp(15)
                                                                  fTable:sine];
        [self connect:fm];
        
        OCSLowPassButterworthFilter *lpFilter = [[OCSLowPassButterworthFilter alloc]
                                                 initWithInput:[fm output]
                                                 cutoffFrequency:[cutoffFrequency control]];
        [self connect:lpFilter];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio = [[OCSAudio alloc] initWithLeftInput:[lpFilter output]
                                                   rightInput:[lpFilter output]];
        [self connect:audio];
    }
    return self;
}

@end


@implementation FivePropertyInstrumentNote

@synthesize volume, frequency;

- (id)initWithInstrument:(OCSInstrument *)anInstrument {
    self = [super initWithInstrument:anInstrument];
    if (self) {
        volume = [[OCSNoteProperty alloc] initWithNote:self
                                          initialValue:kVolumeMin
                                              minValue:kVolumeMin
                                              maxValue:kVolumeMax];
        [self addProperty:volume withName:@"Volume"];
        
        frequency = [[OCSNoteProperty alloc] initWithNote:self
                                         initialValue:kFrequencyMin
                                             minValue:kFrequencyMin
                                             maxValue:kFrequencyMax];
        [self addProperty:frequency withName:@"Frequency"];
    }
    return self;
}


@end
