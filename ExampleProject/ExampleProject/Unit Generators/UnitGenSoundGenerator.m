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
#import "OCSLineSegment.h"
#import "OCSFoscili.h"
#import "OCSOutputStereo.h"

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
        
        OCSLine *myLine = [[OCSLine alloc] initWithStartingValue:ocsp(0.5) 
                                                        Duration:duration 
                                                     TargetValue:ocsp(1.5)];
        [self addOpcode:myLine];

        //Init LineSegment_a, without OCSParamArray Functions like line
        OCSLineSegment *myLineSegment_a = [[OCSLineSegment alloc] initWithFirstSegmentStartValue:ocsp(110)
                                                                            FirstSegmentDuration:duration 
                                                                        FirstSegementTargetValue:ocsp(330)];
        
        OCSParamArray *breakpoints = [OCSParamArray paramArrayFromParams: 
                                       ocsp(3), ocsp(1.5), ocsp(3.0), ocsp(0.5), nil];

        OCSLineSegment *myLineSegment_b = [[OCSLineSegment alloc] initWithFirstSegmentStartValue:ocsp(0.5)
                                                                            FirstSegmentDuration:ocsp(3)
                                                                        FirstSegementTargetValue:ocsp(0.2)
                                                                                    SegmentArray:breakpoints];
        [self addOpcode:myLineSegment_a];
        [self addOpcode:myLineSegment_b];
        
        //H4Y - ARB: create fmOscillator with sine, lines for pitch, modulation, and modindex
        OCSFoscili *myFMOscillator = [[OCSFoscili alloc] initWithAmplitude:ocsp(0.4)
                                                                 Frequency:[myLineSegment_a output]
                                                                   Carrier:ocsp(1)
                                                                Modulation:[myLine output]
                                                                  ModIndex:[myLineSegment_b output]
                                                             FunctionTable:sineTable 
                                                          AndOptionalPhase:nil];
        [self addOpcode:myFMOscillator];

        // AUDIO OUTPUT ========================================================

        OCSOutputStereo *monoOutput = [[OCSOutputStereo alloc] initWithMonoInput:[myFMOscillator output]];
        [self addOpcode:monoOutput];
    }
    return self;
}

@end
