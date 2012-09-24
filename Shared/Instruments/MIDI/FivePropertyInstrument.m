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

@interface FivePropertyInstrument () {
//    OCSEventProperty *vol;
//    OCSEventProperty *freq;
    OCSInstrumentProperty *bend;
    OCSInstrumentProperty *mod;
    OCSInstrumentProperty *cutoff;
}

@end

@implementation FivePropertyInstrument

//@synthesize volume = vol;
//@synthesize frequency = freq;
@synthesize pitchBend = bend;
@synthesize modulation = mod;
@synthesize cutoffFrequency = cutoff;

-(id)init
{
    self = [super init];
    if ( self) {
        
        // INPUTS AND CONTROLS =================================================
//        vol  = [[OCSEventProperty alloc] initWithMinValue:kVolumeMin
//                                                maxValue:kVolumeMax];
//        freq = [[OCSEventProperty alloc] initWithMinValue:kFrequencyMin
//                                                maxValue:kFrequencyMax];
        bend = [[OCSInstrumentProperty alloc] initWithValue:1
                                                   minValue:kPitchBendMin
                                                   maxValue:kPitchBendMax];
        mod = [[OCSInstrumentProperty alloc] initWithMinValue:kModulationMin
                                                     maxValue:kModulationMax];
        cutoff = [[OCSInstrumentProperty alloc] initWithMinValue:kLpCutoffMin
                                                        maxValue:kLpCutoffMax];
        
//        [vol    setConstant:[OCSConstant parameterWithString:@"Volume"]];
//        [freq   setConstant:[OCSConstant parameterWithString:@"Frequency"]];
        [bend   setControl:[OCSControl parameterWithString:@"PitchBend"]];
        [mod    setControl:[OCSControl parameterWithString:@"Modulation"]];
        [cutoff setControl:[OCSControl parameterWithString:@"LowPassCutoff"]];
        
//        [self addEventProperty:vol];
//        [self addEventProperty:freq];
        [self addProperty:bend];
        [self addProperty:mod];
        [self addProperty:cutoff];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSSineTable *sine = [[OCSSineTable alloc] init];
        [self addFTable:sine];
        
//        OCSControl *bentFreq;
//        bentFreq = [[OCSControl alloc] initWithExpression:[NSString stringWithFormat:@"%@  * %@", freq, bend]];
        
  //      OCSFMOscillator *fm = [[OCSFMOscillator alloc] initWithAmplitude:[vol constant]
 //                                                          baseFrequency:bentFreq
 //                                                      carrierMultiplier:ocsp(2)
 //                                                   modulatingMultiplier:[mod control]
//                                                         modulationIndex:ocsp(15)
//                                                                  fTable:sine];
//        [self connect:fm];
        
//        OCSLowPassButterworthFilter *lpFilter = [[OCSLowPassButterworthFilter alloc]
//                                                 initWithInput:[fm output]
//                                                 cutoffFrequency:[cutoff control]];
//        [self connect:lpFilter];
        
        // AUDIO OUTPUT ========================================================
        
//        OCSAudio *audio = [[OCSAudio alloc] initWithLeftInput:[lpFilter output]
//                                                   rightInput:[lpFilter output]];
//        [self connect:audio];
    }
    return self;
}


@end