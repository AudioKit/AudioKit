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

        OCSSegmentArray *reverbDuration;
        reverbDuration = [[OCSSegmentArray alloc] initWithStartValue:ocsp(0)
                                                         toNextValue:ocsp(10) 
                                                       afterDuration:[duration scaledBy:0.25]];
        [reverbDuration addValue:ocsp(10) afterDuration:[duration scaledBy:0.75]];
        [reverbDuration addValue:ocsp(0)  afterDuration:[duration scaledBy:0.8]];
        [reverbDuration setOutput:[reverbDuration control]];
        [self addOpcode:reverbDuration];
        
        OCSReverbSixParallelComb * reverb;
        reverb = [[OCSReverbSixParallelComb alloc]  initWithInput:input 
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
