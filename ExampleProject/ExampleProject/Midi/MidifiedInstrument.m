//
//  MidifiedInstrument.m
//  Objective-Csound
//
//  Created by Adam Boulanger on 7/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "MidifiedInstrument.h"
#import "OCSAudio.h"
#import "OCSSineTable.h"
#import "OCSLowPassButterworthFilter.h"
#import "OCSFMOscillator.h"
#import "OCSMidiManager.h"

@interface MidifiedInstrument () {
    OCSProperty *frequency;
    OCSProperty *modulation;
    OCSProperty *lowPassCutoffFrequency;
}

@end

@implementation MidifiedInstrument
@synthesize frequency = freq;
@synthesize modulation = mod;
@synthesize lowPassCutoffFrequency = cutoff;

-(id)init
{
    self = [super init];
    if ( self) {
        
        // INPUTS AND CONTROLS =================================================
        freq = [[OCSProperty alloc] initWithValue:((kFrequencyMax + kFrequencyMin) / 2) 
                                         minValue:kFrequencyMin 
                                         maxValue:kFrequencyMax];
        mod = [[OCSProperty alloc] initWithValue:((kModulationMax + kModulationMin)/2)
                                        minValue:kModulationMin 
                                        maxValue:kModulationMax];
        cutoff = [[OCSProperty alloc] initWithValue:kLpCutoffInit 
                                           minValue:kLpCutoffMin 
                                           maxValue:kLpCutoffMax];
        [cutoff enableMidiForChannelNumber:1];
        
        [freq setControl:[OCSControl parameterWithString:@"Frequency"]];
        [mod setControl:[OCSControl parameterWithString:@"Modulation"]];
        [cutoff setControl:[OCSControl parameterWithString:@"LowPassCutoff"]];
        
        [self addProperty:freq];
        [self addProperty:mod];
        [self addProperty:cutoff];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSSineTable *sine = [[OCSSineTable alloc] init];
        [self addFTable:sine];
        
        OCSFMOscillator *fm = [[OCSFMOscillator alloc] initWithAmplitude:ocsp(0.2) 
                                                           baseFrequency:[freq control] 
                                                       carrierMultiplier:ocsp(2) 
                                                    modulatingMultiplier:[mod control] 
                                                         modulationIndex:ocsp(15) 
                                                                  fTable:sine];
        [self addOpcode:fm];
        
        OCSLowPassButterworthFilter *lpFilter = [[OCSLowPassButterworthFilter alloc] 
                                                 initWithInput:[fm output] 
                                                 cutoffFrequency:[cutoff control]];
        [self addOpcode:lpFilter];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio = [[OCSAudio alloc] initWithLeftInput:[lpFilter output]
                                                   rightInput:[lpFilter output]];
        [self addOpcode:audio];
    }
    return self;
}

- (void)playNoteForDuration:(float)noteDuration 
                  Frequency:(float)noteFrequency
                 Modulation:(float)noteModulation
{
    frequency.value = noteFrequency;
    modulation.value = noteModulation;
    [self playNoteForDuration:noteDuration];
}

@end
