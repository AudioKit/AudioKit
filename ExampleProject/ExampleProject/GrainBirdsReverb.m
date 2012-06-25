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
#import "OCSOutputStereo.h"

@implementation GrainBirdsReverb

- (id)initWithGrainBirds:(GrainBirds *)grainBirds
{
    self = [super init];
    if (self) {                  
        
        // INPUTS ==============================================================
        
        OCSParam * input = [grainBirds auxilliaryOutput];
        
        // INSTRUMENT DEFINITION ===============================================
        
        //ARB - Bug here in duration expressions not adding up to 1
        
        OCSParamArray *arr = [OCSParamArray paramArrayFromParams:[OCSParamConstant paramWithFormat:@"%@ * 0.75", duration], ocsp(10), [OCSParamConstant paramWithFormat:@"0.8 * %@", duration], ocsp(0), nil]; 
        
        OCSLineSegment *reverbDuration = [[OCSLineSegment alloc] 
                                initWithFirstSegmentStartValue:ocsp(0)
                                          FirstSegmentDuration:[OCSParamConstant paramWithFormat:@"%@ * 0.25", duration] 
                                      FirstSegementTargetValue:ocsp(10) 
                                                  SegmentArray:arr];
        [self addOpcode:reverbDuration];
        
        OCSReverbSixParallelComb * reverb = [[OCSReverbSixParallelComb alloc] 
                                             initWithInput:input 
                                            ReverbDuration:[reverbDuration output] 
                                       HighFreqDiffusivity:ocsp(0)];

        [self addOpcode:reverb];
        
        // AUDIO OUTPUT ========================================================

        OCSOutputStereo * stereoOutput = [[OCSOutputStereo alloc] initWithMonoInput:[reverb output]];
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
