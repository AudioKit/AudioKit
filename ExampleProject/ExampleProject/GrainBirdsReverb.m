//
//  GrainBirdsReverb.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/25/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "GrainBirdsReverb.h"
#import "OCSReverbSixParallelComb.h"
#import "OCSLineSegment.h"
#import "OCSAudio.h"

@implementation GrainBirdsReverb

- (id)initWithGrainBirds:(GrainBirds *)grainBirds
{
    self = [super init];
    if (self) {                  
        
        // INPUTS ==============================================================
        
        OCSParam * input = [grainBirds auxilliaryOutput];
        
        // INSTRUMENT DEFINITION ===============================================
        
        //ARB - Bug here in duration expressions not adding up to 1

        OCSParamConstant * quarterDuration      = [OCSParamConstant paramWithFormat:@"%@ * 0.25", duration];
        OCSParamConstant * threeQuarterDuration = [OCSParamConstant paramWithFormat:@"%@ * 0.75", duration];
        OCSParamConstant * fourFifthsDuration   = [OCSParamConstant paramWithFormat:@"%@ * 0.8",  duration];

        OCSParamArray *arr = [OCSParamArray paramArrayFromParams:
                              threeQuarterDuration, ocsp(10), fourFifthsDuration, ocsp(0), nil]; 
        
        OCSLineSegment *reverbDuration = [[OCSLineSegment alloc] initWithFirstSegmentStartValue:ocsp(0)
                                                                        FirstSegmentTargetValue:ocsp(10) 
                                                                           FirstSegmentDuration:quarterDuration
                                                                             DurationValuePairs:arr];
        [self addOpcode:reverbDuration];
        
        OCSReverbSixParallelComb * reverb = [[OCSReverbSixParallelComb alloc] 
                                             initWithInput:input 
                                            ReverbDuration:[reverbDuration output] 
                                       HighFreqDiffusivity:ocsp(0)];

        [self addOpcode:reverb];
        
        // AUDIO OUTPUT ========================================================

        OCSAudio * stereoOutput = [[OCSAudio alloc] initWithMonoInput:[reverb output]];
        [self addOpcode:stereoOutput];

        // RESET INPUTS ========================================================
        [self resetParam:input];

    }
    return self;
}

- (void)start {
    [self playNoteForDuration:10000.0f];
}

@end
