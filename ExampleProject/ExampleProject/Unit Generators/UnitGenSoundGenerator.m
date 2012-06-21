//
//  UnitGenSoundGenerator.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UnitGenSoundGenerator.h"

#import "CSDSineTable.h"
#import "CSDParam.h"
#import "CSDParamArray.h"
#import "CSDSum.h"

@implementation UnitGenSoundGenerator

-(id)initWithOrchestra:(CSDOrchestra *)newOrchestra
{
    self = [super initWithOrchestra:newOrchestra];
    if (self) {
        
        // INSTRUMENT DEFINITION ===============================================
        
        //H4Y - ARB: create sign function with variable partial strengths
        float partialStrengthFloats[] = {1.0f, 0.5f, 1.0f};
        CSDParamArray * partialStrengths= [CSDParamArray paramArrayFromFloats:partialStrengthFloats count:3];
        CSDSineTable * sineTable = [[CSDSineTable alloc] initWithTableSize:4096 
                                                          PartialStrengths:partialStrengths];
        [self addFunctionTable:sineTable];
        
        myLine = [[CSDLine alloc] initWithStartingValue:[CSDParamConstant paramWithFloat:0.5] 
                                               Duration:duration 
                                            TargetValue:[CSDParamConstant paramWithInt:1.5]];
        [self addOpcode:myLine];

        //Init LineSegment_a, without CSDParamArray Functions like line
        myLineSegment_a = 
        [[CSDLineSegment alloc] initWithFirstSegmentStartValue:[CSDParamConstant paramWithInt:110]
                                          FirstSegmentDuration:duration 
                                      FirstSegementTargetValue:[CSDParamConstant paramWithInt:330]];
        
        CSDParamArray * breakpoints = [CSDParamArray paramArrayFromParams:
                                       [CSDParamConstant paramWithFloat:3.0f],
                                       [CSDParamConstant paramWithFloat:1.5f],
                                       [CSDParamConstant paramWithFloat:3.0f], 
                                       [CSDParamConstant paramWithFloat:0.5f],nil];

        myLineSegment_b = 
        [[CSDLineSegment alloc] initWithFirstSegmentStartValue:[CSDParamConstant paramWithFloat:0.5]
                                          FirstSegmentDuration:[CSDParamConstant paramWithInt:3]
                                      FirstSegementTargetValue:[CSDParamConstant paramWithFloat:0.2] 
                                                  SegmentArray:breakpoints];
        [self addOpcode:myLineSegment_a];
        [self addOpcode:myLineSegment_b];
        
        //H4Y - ARB: create fmOscillator with sine, lines for pitch, modulation, and modindex
        myFMOscillator = 
        [[CSDFoscili alloc] initWithAmplitude:[CSDParamConstant paramWithFloat:0.4] 
                                    Frequency:[myLineSegment_a output]
                                      Carrier:[CSDParamConstant paramWithInt:1]
                                   Modulation:[myLine output]
                                     ModIndex:[myLineSegment_b output]
                                FunctionTable:sineTable 
                             AndOptionalPhase:nil];
        
        [self addOpcode:myFMOscillator];

        // AUDIO OUTPUT ========================================================

        CSDOutputStereo * monoOutput = 
        [[CSDOutputStereo alloc] initWithMonoInput:[myFMOscillator output]];
        [self addOpcode:monoOutput];
    }
    return self;
}

-(void)playNoteForDuration:(float)dur 
{
    [self playNoteWithDuration:dur];
}

@end
