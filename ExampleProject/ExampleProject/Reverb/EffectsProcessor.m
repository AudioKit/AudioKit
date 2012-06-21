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

-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra ToneGenerator:(ToneGenerator *)toneGenerator
{
    self = [super initWithOrchestra:newOrchestra];
    if (self) {                  
        
        // INPUTS ==============================================================
        
        input = [toneGenerator auxilliaryOutput];
        
        // INSTRUMENT DEFINITION ===============================================
        
        CSDReverb * reverb = 
        [[CSDReverb alloc] initWithMonoInput:input
                               FeedbackLevel:[CSDParamConstant paramWithFloat:0.9f] 
                             CutoffFrequency:[CSDParamConstant paramWithInt:1200]];
        [self addOpcode:reverb];
        
        // AUDIO OUTPUT ========================================================
            
        CSDOutputStereo * stereoOutput = 
        [[CSDOutputStereo alloc] initWithInputLeft:[reverb outputLeft] 
                                        InputRight:[reverb outputRight]]; 
        [self addOpcode:stereoOutput];
        
        // RESET INPUTS ========================================================
        [self resetParam:input];
    }
    return self;
}

-(void) start {
    [self playNoteWithDuration:10000.0f];
}

@end
