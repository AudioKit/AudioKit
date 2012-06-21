//
//  SoundGenerator.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  NOTE: Alternate sineTable definition:
//  float partialStrengths[] = {1.0f, 0.5f, 1.0f};
//  CSDParamArray * partialStrengthParamArray = [CSDParamArray paramArrayFromFloats:partialStrengths count:3];


#import "SoundGenerator.h"

@implementation SoundGenerator

@synthesize frequency;

-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra {
    self = [super initWithOrchestra:newOrchestra];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
        
        frequency  = [[CSDProperty alloc] init];
        [frequency  setOutput:[CSDParamControl paramWithString:@"Frequency"]]; 
        [self addProperty:frequency];
        
        // INSTRUMENT DEFINITION ===============================================
        
        CSDParamArray * partialStrengthParamArray = [CSDParamArray paramArrayFromParams:
                                                     [CSDParamConstant paramWithFloat:1.0f],
                                                     [CSDParamConstant paramWithFloat:0.5f],
                                                     [CSDParamConstant paramWithFloat:1.0f], nil];
        
        CSDSineTable * sineTable = [[CSDSineTable alloc] initWithTableSize:4096 
                                                          PartialStrengths:partialStrengthParamArray];
        [self addFunctionTable:sineTable];
        
        CSDOscillator * myOscillator = [[CSDOscillator alloc] 
                                        initWithAmplitude:[CSDParamConstant paramWithFloat:0.12]
                                                Frequency:[frequency output]
                                            FunctionTable:sineTable];
        [self addOpcode:myOscillator];
        
        CSDReverb * reverb = [[CSDReverb alloc] initWithInputLeft:[myOscillator output] 
                                                       InputRight:[myOscillator output] 
                                                    FeedbackLevel:[CSDParamConstant paramWithFloat:0.85f] 
                                                  CutoffFrequency:[CSDParamConstant paramWithInt:12000]];
        
        [self addOpcode:reverb];
        
        // AUDIO OUTPUT ========================================================
        
        CSDOutputStereo * stereoOutput = 
        [[CSDOutputStereo alloc] initWithInputLeft:[reverb outputLeft] 
                                        InputRight:[reverb outputRight]]; 
        [self addOpcode:stereoOutput];
    }
    return self;
}

-(void) playNoteForDuration:(float)dur Frequency:(float)freq {
    frequency.value = freq;
    [self playNoteWithDuration:dur];
}

@end
