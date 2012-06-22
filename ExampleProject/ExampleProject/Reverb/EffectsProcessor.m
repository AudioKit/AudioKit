//
//  EffectsProcessor.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "EffectsProcessor.h"

@implementation EffectsProcessor
@synthesize input;

-(id) initWithOrchestra:(OCSOrchestra *)newOrchestra ToneGenerator:(ToneGenerator *)toneGenerator
{
    self = [super initWithOrchestra:newOrchestra];
    if (self) {                  
        
        // INPUTS ==============================================================
        
        input = [toneGenerator auxilliaryOutput];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSReverb * reverb = 
        [[OCSReverb alloc] initWithMonoInput:input
                               FeedbackLevel:[OCSParamConstant paramWithFloat:0.9f] 
                             CutoffFrequency:[OCSParamConstant paramWithInt:1200]];
        [self addOpcode:reverb];
        
        // AUDIO OUTPUT ========================================================
            
        OCSOutputStereo * stereoOutput = 
        [[OCSOutputStereo alloc] initWithInputLeft:[reverb outputLeft] 
                                        InputRight:[reverb outputRight]]; 
        [self addOpcode:stereoOutput];
        
        // RESET INPUTS ========================================================
        [self resetParam:input];
    }
    return self;
}

-(void) start {
    [self playNoteForDuration:10000.0f];
}

@end
