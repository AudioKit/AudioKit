//
//  UnitGenSoundGenerator.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UnitGenSoundGenerator.h"
#import "OCSSineTable.h"
#import "OCSLine.h"
#import "OCSSegmentArray.h"
#import "OCSFoscili.h"
#import "OCSAudio.h"

@implementation UnitGenSoundGenerator

- (id)init
{
    self = [super init];
    if (self) {
        
        // INSTRUMENT DEFINITION ===============================================
        // create sign function with variable partial strengths

        OCSParamArray *partialStrengths;
        partialStrengths = [OCSParamArray paramArrayFromParams:
                            ocsp(1.0f), ocsp(0.5f), ocsp(1.0f), nil];
        OCSSineTable *sine;
        sine = [[OCSSineTable alloc] initWithSize:4096 
                                 partialStrengths:partialStrengths];
        [self addFunctionTable:sine];
        
        OCSLine *myLine = [[OCSLine alloc] initFromValue:ocsp(0.5) 
                                                 ToValue:ocsp(1.5)
                                                Duration:duration];
        [self addOpcode:myLine];

        //Init LineSegment_a, without OCSParamArray Functions like line
        OCSLine *baseFrequencyLine = [[OCSLine alloc] initFromValue:ocsp(110) 
                                                            ToValue:ocsp(330)
                                                           Duration:duration];
        [baseFrequencyLine setOutput:[baseFrequencyLine control]];
        [self addOpcode:baseFrequencyLine];
        
        OCSSegmentArray *modIndexLine;
        modIndexLine = [[OCSSegmentArray alloc] initWithStartValue:ocsp(0.5)
                                                       toNextValue:ocsp(0.2)
                                                          afterDuration:ocsp(3)];
        [modIndexLine addValue:ocsp(1.5) afterDuration:ocsp(3)];
        [modIndexLine addValue:ocsp(0.5) afterDuration:ocsp(3)];
        [modIndexLine setOutput:[modIndexLine control]];
        [self addOpcode:modIndexLine];
        
        // create fmOscillator with sine, lines for pitch, modulation, and modindex
        OCSFoscili *fmOscillator;
        fmOscillator = [[OCSFoscili alloc] initWithAmplitude:ocsp(0.4)
                                               BaseFrequency:[baseFrequencyLine control]
                                           CarrierMultiplier:ocsp(1) 
                                        ModulatingMultiplier:[myLine output]
                                             ModulationIndex:[modIndexLine control]
                                               FunctionTable:sine];
        [self addOpcode:fmOscillator];

        // AUDIO OUTPUT ========================================================

        OCSAudio *audio = [[OCSAudio alloc] initWithMonoInput:[fmOscillator output]];
        [self addOpcode:audio];
    }
    return self;
}

@end
