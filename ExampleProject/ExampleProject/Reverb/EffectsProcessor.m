//
//  EffectsProcessor.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "EffectsProcessor.h"
#import "OCSReverb.h"
#import "OCSOutputStereo.h"

@implementation EffectsProcessor

- (id)initWithToneGenerator:(ToneGenerator *)toneGenerator
{
    self = [super init];
    if (self) {                  
        
        // INPUTS ==============================================================
        
        OCSParam * input = [toneGenerator auxilliaryOutput];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSReverb * reverb = [[OCSReverb alloc] initWithMonoInput:input
                                                    FeedbackLevel:ocsp(0.9)
                                                  CutoffFrequency:ocsp(12000)];
        [self addOpcode:reverb];
        
        // AUDIO OUTPUT ========================================================
            
        OCSOutputStereo * stereoOutput = [[OCSOutputStereo alloc] initWithInputLeft:[reverb outputLeft] 
                                                                         InputRight:[reverb outputRight]]; 
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
