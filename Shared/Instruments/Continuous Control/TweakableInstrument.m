//
//  TweakableInstrument.m
//  Objective-C Sound Example
//
//  Created by Adam Boulanger on 6/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "TweakableInstrument.h"
#import "OCSSineTable.h"
#import "OCSFMOscillator.h"
#import "OCSAudioOutput.h"
#import "OCSAssignment.h"


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
                
        [self addProperty:amplitude];
        [self addProperty:frequency];
        [self addProperty:modulation];
        [self addProperty:modIndex];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSSineTable *sineTable = [[OCSSineTable alloc] init];
        [self addFTable:sineTable];
        
        OCSFMOscillator *fmOscil;
        fmOscil = [[OCSFMOscillator alloc] initWithFTable:sineTable
                                            baseFrequency:frequency
                                        carrierMultiplier:ocsp(1)
                                     modulatingMultiplier:modulation
                                          modulationIndex:modIndex
                                                amplitude:amplitude];
        [self connect:fmOscil];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudioOutput *audio = [[OCSAudioOutput alloc] initWithAudioSource:fmOscil];
        [self connect:audio];
        
        /*
        // Test to show amplitude slider moving also
        [self addString:[NSString stringWithFormat:
         @"%@ = %@ + 0.001\n", amplitude, amplitude]];
         */
    }
    return self;
}
@end
