//
//  UnitGeneratorInstrument.m
//  Objective-C Sound Example
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UnitGeneratorInstrument.h"
#import "OCSSineTable.h"
#import "OCSLine.h"
#import "OCSLinearControl.h"
#import "OCSControlSegmentArray.h"
#import "OCSFMOscillator.h"
#import "OCSAudioOutput.h"

@implementation UnitGeneratorInstrument

- (id)init
{
    self = [super init];
    if (self) {
        
        // INSTRUMENT DEFINITION ===============================================
        // create sign function with variable partial strengths

        OCSArray *partialStrengths;
        partialStrengths = [OCSArray arrayFromParams:
                            ocsp(1.0f), ocsp(0.5f), ocsp(1.0f), nil];
        OCSSineTable *sine;
        sine = [[OCSSineTable alloc] initWithSize:4096 
                                 partialStrengths:partialStrengths];
        [sine setIsNormalized:YES];
        [self addFTable:sine];
        
        OCSLine *myLine = [[OCSLine alloc] initFromValue:ocsp(0.5) 
                                                 toValue:ocsp(1.5)
                                                duration:ocsp(3.0)];
        [self connect:myLine];

        //Init LineSegment_a, without OCSArray Functions like line
        OCSLinearControl *baseFrequencyLine;
        baseFrequencyLine = [[OCSLinearControl alloc] initFromValue:ocsp(110)
                                                            toValue:ocsp(330)
                                                           duration:ocsp(3.0)];
        [self connect:baseFrequencyLine];
        
        OCSControlSegmentArray *modIndexLine;
        modIndexLine = [[OCSControlSegmentArray alloc] initWithStartValue:ocsp(0.5)
                                                              toNextValue:ocsp(0.2)
                                                            afterDuration:ocsp(3)];
        [modIndexLine addValue:ocsp(1.5) afterDuration:ocsp(3)];
        [modIndexLine addValue:ocsp(0.5) afterDuration:ocsp(3)];
        [self connect:modIndexLine];
        
        // create fmOscillator with sine, lines for pitch, modulation, and modindex
        OCSFMOscillator *fmOscil;
        fmOscil = [[OCSFMOscillator alloc] initWithFTable:sine
                                            baseFrequency:baseFrequencyLine
                                        carrierMultiplier:ocsp(1)
                                     modulatingMultiplier:myLine
                                          modulationIndex:modIndexLine
                                                amplitude:ocsp(0.4)];
        [self connect:fmOscil];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudioOutput *audio = [[OCSAudioOutput alloc] initWithAudioSource:fmOscil];
        [self connect:audio];
    }
    return self;
}

@end
