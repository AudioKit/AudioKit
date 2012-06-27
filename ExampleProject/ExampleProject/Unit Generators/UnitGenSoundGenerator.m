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
        
        //H4Y - ARB: create sign function with variable partial strengths
        float partialStrengthFloats[] = {1.0f, 0.5f, 1.0f};
        OCSParamArray *partialStrengths= [OCSParamArray paramArrayFromFloats:partialStrengthFloats count:3];
        OCSSineTable *sineTable = [[OCSSineTable alloc] initWithSize:4096 
                                                     PartialStrengths:partialStrengths];
        [self addFunctionTable:sineTable];
        
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

        OCSSegmentArray *modIndexLine = [[OCSSegmentArray alloc] initWithFirstSegmentStartValue:ocsp(0.5)
                                                                                    FirstSegmentTargetValue:ocsp(0.2)
                                                                                       FirstSegmentDuration:ocsp(3)];
        [modIndexLine addNextSegmentTargetValue:ocsp(1.5) AfterDuration:ocsp(3)];
        [modIndexLine addNextSegmentTargetValue:ocsp(0.5) AfterDuration:ocsp(3)];
        [modIndexLine setOutput:[modIndexLine control]];
        [self addOpcode:modIndexLine];
        
        //H4Y - ARB: create fmOscillator with sine, lines for pitch, modulation, and modindex
        OCSFoscili *myFMOscillator = [[OCSFoscili alloc] initWithAmplitude:ocsp(0.4)
                                                             BaseFrequency:[baseFrequencyLine control]
                                                         CarrierMultiplier:ocsp(1) 
                                                      ModulatingMultiplier:[myLine output]
                                                           ModulationIndex:[modIndexLine control]
                                                             FunctionTable:sineTable];
        [self addOpcode:myFMOscillator];

        // AUDIO OUTPUT ========================================================

        OCSAudio *audio = [[OCSAudio alloc] initWithMonoInput:[myFMOscillator output]];
        [self addOpcode:audio];
    }
    return self;
}

@end
