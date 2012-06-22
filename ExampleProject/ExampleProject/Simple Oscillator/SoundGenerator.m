//
//  SoundGenerator.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  NOTE: Alternate sineTable definition:
//  float partialStrengths[] = {1.0f, 0.5f, 1.0f};
//  OCSParamArray * partialStrengthParamArray = [OCSParamArray paramArrayFromFloats:partialStrengths count:3];


#import "SoundGenerator.h"

@implementation SoundGenerator

@synthesize frequency;

-(id) initWithOrchestra:(OCSOrchestra *)newOrchestra {
    self = [super initWithOrchestra:newOrchestra];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
        
        frequency  = [[OCSProperty alloc] init];
        [frequency  setOutput:[OCSParamControl paramWithString:@"Frequency"]]; 
        [self addProperty:frequency];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSParamArray * partialStrengthParamArray = [OCSParamArray paramArrayFromParams:
                                                     [OCSParamConstant paramWithFloat:1.0f],
                                                     [OCSParamConstant paramWithFloat:0.5f],
                                                     [OCSParamConstant paramWithFloat:1.0f], nil];
        
        OCSSineTable * sineTable = [[OCSSineTable alloc] initWithSize:4096 
                                                     PartialStrengths:partialStrengthParamArray];
        [self addFunctionTable:sineTable];
        
        OCSOscillator * myOscillator = [[OCSOscillator alloc] 
                                        initWithAmplitude:[OCSParamConstant paramWithFloat:0.12]
                                                Frequency:[frequency output]
                                            FunctionTable:sineTable];
        [self addOpcode:myOscillator];
        
        OCSReverb * reverb = [[OCSReverb alloc] initWithInputLeft:[myOscillator output] 
                                                       InputRight:[myOscillator output] 
                                                    FeedbackLevel:[OCSParamConstant paramWithFloat:0.85f] 
                                                  CutoffFrequency:[OCSParamConstant paramWithInt:12000]];
        
        [self addOpcode:reverb];
        
        // AUDIO OUTPUT ========================================================
        
        OCSOutputStereo * stereoOutput = 
        [[OCSOutputStereo alloc] initWithInputLeft:[reverb outputLeft] 
                                        InputRight:[reverb outputRight]]; 
        [self addOpcode:stereoOutput];
    }
    return self;
}

-(void) playNoteForDuration:(float)dur Frequency:(float)freq {
    frequency.value = freq;
    [self playNoteForDuration:dur];
}

@end
