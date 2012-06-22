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

-(id) initWithOrchestra:(OCSOrchestra *)orch 
          ToneGenerator:(ToneGenerator *)toneGenerator
{
    self = [super initWithOrchestra:orch];
    if (self) {                  
        
        // INPUTS ==============================================================
        
        input = [toneGenerator auxilliaryOutput];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSReverb * reverb = 
        [[OCSReverb alloc] initWithMonoInput:input
                               FeedbackLevel:ocsp(0.9)
                             CutoffFrequency:ocsp(12000)];
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
