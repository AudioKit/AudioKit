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
#import "OCSSegmentArray.h"
#import "OCSFMOscillator.h"
#import "OCSAudio.h"

@implementation UnitGeneratorInstrument

- (id)init
{
    self = [super init];
    if (self) {
        
        // INSTRUMENT DEFINITION ===============================================
        // create sign function with variable partial strengths

        OCSParameterArray *partialStrengths;
        partialStrengths = [OCSParameterArray paramArrayFromParams:
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

        //Init LineSegment_a, without OCSParameterArray Functions like line
        OCSLine *baseFrequencyLine = [[OCSLine alloc] initFromValue:ocsp(110) 
                                                            toValue:ocsp(330)
                                                           duration:ocsp(3.0)];
        [baseFrequencyLine setOutput:[baseFrequencyLine control]];
        [self connect:baseFrequencyLine];
        
        OCSSegmentArray *modIndexLine;
        modIndexLine = [[OCSSegmentArray alloc] initWithStartValue:ocsp(0.5)
                                                       toNextValue:ocsp(0.2)
                                                          afterDuration:ocsp(3)];
        [modIndexLine addValue:ocsp(1.5) afterDuration:ocsp(3)];
        [modIndexLine addValue:ocsp(0.5) afterDuration:ocsp(3)];
        [modIndexLine setOutput:[modIndexLine control]];
        [self connect:modIndexLine];
        
        // create fmOscillator with sine, lines for pitch, modulation, and modindex
        OCSFMOscillator *fmOscillator;
        fmOscillator = [[OCSFMOscillator alloc] initWithAmplitude:ocsp(0.4)
                                                    baseFrequency:[baseFrequencyLine control]
                                                carrierMultiplier:ocsp(1) 
                                             modulatingMultiplier:[myLine output]
                                                  modulationIndex:[modIndexLine control]
                                                           fTable:sine];
        [self connect:fmOscillator];

        // AUDIO OUTPUT ========================================================

        OCSAudio *audio = [[OCSAudio alloc] initWithMonoInput:[fmOscillator output]];
        [self connect:audio];
    }
    return self;
}

@end
