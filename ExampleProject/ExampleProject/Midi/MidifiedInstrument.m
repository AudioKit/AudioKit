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
        freq = [[OCSProperty alloc] initWithMinValue:kFrequencyMin maxValue:kFrequencyMax];
        mod = [[OCSProperty alloc] initWithMinValue:kModulationMin maxValue:kModulationMax];
        cutoff = [[OCSProperty alloc] initWithValue:kLpCutoffInit minValue:kLpCutoffMin maxValue:kLpCutoffMax];
        
        [cutoff enableMidiForChannelNumber:16];
        /*[cutoff enableMidi];
        [cutoff setChannelNumber:16];*/
        
        [freq setControl:[OCSControl parameterWithString:@"Frequency"]];
        [mod setControl:[OCSControl parameterWithString:@"Modulation"]];
        [cutoff setControl:[OCSControl parameterWithString:@"LowPassCutoff"]];
        
        [self addProperty:freq];
        [self addProperty:mod];
        [self addProperty:cutoff];
        
        // INSTRUMENT DEFINITION ===============================================
        
        
        
        // AUDIO OUTPUT ========================================================
        /*
        OCSAudio *audio = [[OCSAudio alloc] initWithLeftInput:[fmOscillator output]
                                                   rightInput:[fmOscillator output]];
        [self addOpcode:audio];*/
    }
    return self;
}

- (void)playNoteForDuration:(float)noteDuration 
                  Frequency:(float)noteFrequency
                 Modulation:(float)noteModulation
{}

@end
