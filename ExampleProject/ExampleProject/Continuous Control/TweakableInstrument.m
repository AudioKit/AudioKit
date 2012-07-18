//
//  TweakableInstrument.m
//  Objective-Csound Example
//
//  Created by Adam Boulanger on 6/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "TweakableInstrument.h"
#import "OCSSineTable.h"
#import "OCSFMOscillator.h"
#import "OCSAudio.h"
#import "OCSAssignment.h"

@interface TweakableInstrument ()
{
    //OCSPropertyManager *myPropertyManager;
    
    //maintain reference to properties so they can be referenced from controlling game logic 
    OCSInstrumentProperty *amplitude;
    OCSInstrumentProperty *frequency;
    OCSInstrumentProperty *modulation;
    OCSInstrumentProperty *modIndex;
}
@end


@implementation TweakableInstrument
@synthesize amplitude;
@synthesize frequency;
@synthesize modulation;
@synthesize modIndex;
- (id)init
{
    self = [super init];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
    
        amplitude  = [[OCSInstrumentProperty alloc] initWithValue:kTweakableAmplitudeInit  minValue:kTweakableAmplitudeMin  maxValue:kTweakableAmplitudeMax];
        frequency  = [[OCSInstrumentProperty alloc] initWithValue:kTweakableFrequencyInit  minValue:kTweakableFrequencyMin  maxValue:kTweakableFrequencyMax];
        modulation = [[OCSInstrumentProperty alloc] initWithValue:kTweakableModulationInit minValue:kTweakableModulationMin maxValue:kTweakableModulationMax];
        modIndex   = [[OCSInstrumentProperty alloc] initWithValue:kTweakableModIndexInit   minValue:kTweakableModIndexMin   maxValue:kTweakableModIndexMax];
        
        [amplitude  setControl:[OCSControl parameterWithString:@"Amplitude"]]; 
        [frequency  setControl:[OCSControl parameterWithString:@"Frequency"]]; 
        [modulation setControl:[OCSControl parameterWithString:@"Modulation"]]; 
        [modIndex   setControl:[OCSControl parameterWithString:@"ModIndex"]]; 
        
        [self addProperty:amplitude];
        [self addProperty:frequency];
        [self addProperty:modulation];
        [self addProperty:modIndex];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSSineTable *sineTable = [[OCSSineTable alloc] init];
        [self addFTable:sineTable];
        
        OCSFMOscillator *fmOscillator;
        fmOscillator = [[OCSFMOscillator alloc] initWithAmplitude:[amplitude control] 
                                                    baseFrequency:[frequency control] 
                                                carrierMultiplier:ocsp(1) 
                                             modulatingMultiplier:[modulation control] 
                                                  modulationIndex:[modIndex control] 
                                                           fTable:sineTable];
        [self addOpcode:fmOscillator];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio = [[OCSAudio alloc] initWithMonoInput:[fmOscillator output]];
        [self addOpcode:audio];
        
        /*
        // Test to show amplitude slider moving also
        [self addString:[NSString stringWithFormat:
         @"%@ = %@ + 0.001\n", amplitude, amplitude]];
         */
    }
    return self;
}
@end
