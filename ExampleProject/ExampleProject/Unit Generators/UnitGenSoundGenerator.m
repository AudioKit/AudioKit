//
//  UnitGenSoundGenerator.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UnitGenSoundGenerator.h"

#import "OCSSineTable.h"
#import "OCSParam.h"
#import "OCSParamArray.h"
#import "OCSSum.h"

@implementation UnitGenSoundGenerator

-(id)initWithOrchestra:(OCSOrchestra *)orch
{
    self = [super initWithOrchestra:orch];
    if (self) {
        
        // INSTRUMENT DEFINITION ===============================================
        
        //H4Y - ARB: create sign function with variable partial strengths
        float partialStrengthFloats[] = {1.0f, 0.5f, 1.0f};
        OCSParamArray * partialStrengths= [OCSParamArray paramArrayFromFloats:partialStrengthFloats count:3];
        OCSSineTable * sineTable = [[OCSSineTable alloc] initWithSize:4096 
                                                     PartialStrengths:partialStrengths];
        [self addFunctionTable:sineTable];
        
        myLine = [[OCSLine alloc] initWithStartingValue:[OCSParamConstant paramWithFloat:0.5] 
                                               Duration:duration 
                                            TargetValue:[OCSParamConstant paramWithInt:1.5]];
        [self addOpcode:myLine];

        //Init LineSegment_a, without OCSParamArray Functions like line
        myLineSegment_a = 
        [[OCSLineSegment alloc] initWithFirstSegmentStartValue:[OCSParamConstant paramWithInt:110]
                                          FirstSegmentDuration:duration 
                                      FirstSegementTargetValue:[OCSParamConstant paramWithInt:330]];
        
        OCSParamArray * breakpoints = [OCSParamArray paramArrayFromParams:
                                       [OCSParamConstant paramWithFloat:3.0f],
                                       [OCSParamConstant paramWithFloat:1.5f],
                                       [OCSParamConstant paramWithFloat:3.0f], 
                                       [OCSParamConstant paramWithFloat:0.5f],nil];

        myLineSegment_b = 
        [[OCSLineSegment alloc] initWithFirstSegmentStartValue:[OCSParamConstant paramWithFloat:0.5]
                                          FirstSegmentDuration:[OCSParamConstant paramWithInt:3]
                                      FirstSegementTargetValue:[OCSParamConstant paramWithFloat:0.2] 
                                                  SegmentArray:breakpoints];
        [self addOpcode:myLineSegment_a];
        [self addOpcode:myLineSegment_b];
        
        //H4Y - ARB: create fmOscillator with sine, lines for pitch, modulation, and modindex
        myFMOscillator = 
        [[OCSFoscili alloc] initWithAmplitude:[OCSParamConstant paramWithFloat:0.4] 
                                    Frequency:[myLineSegment_a output]
                                      Carrier:[OCSParamConstant paramWithInt:1]
                                   Modulation:[myLine output]
                                     ModIndex:[myLineSegment_b output]
                                FunctionTable:sineTable 
                             AndOptionalPhase:nil];
        
        [self addOpcode:myFMOscillator];

        // AUDIO OUTPUT ========================================================

        OCSOutputStereo * monoOutput = 
        [[OCSOutputStereo alloc] initWithMonoInput:[myFMOscillator output]];
        [self addOpcode:monoOutput];
    }
    return self;
}

@end
