//
//  GrainBirdsReverb.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/25/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "GrainBirdsReverb.h"
#import "OCSReverbSixParallelComb.h"
#import "OCSSegmentArray.h"
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

        OCSSegmentArray *reverbDuration = [[OCSSegmentArray alloc] initWithFirstSegmentStartValue:ocsp(0)
                                                                        FirstSegmentTargetValue:ocsp(10) 
                                                                             FirstSegmentDuration:quarterDuration];
        [reverbDuration addNextSegmentTargetValue:ocsp(10) AfterDuration:threeQuarterDuration];
        [reverbDuration addNextSegmentTargetValue:ocsp(0)  AfterDuration:fourFifthsDuration];
        [reverbDuration setOutput:[reverbDuration control]];
        [self addOpcode:reverbDuration];
        
        OCSReverbSixParallelComb * reverb = [[OCSReverbSixParallelComb alloc]  initWithInput:input 
                                                                              ReverbDuration:[reverbDuration control] 
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
