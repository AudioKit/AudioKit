//
//  AudioFilePlayer.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AudioFilePlayer.h"

@implementation AudioFilePlayer


-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra {
    self = [super initWithOrchestra:newOrchestra];
    if (self) {
        
        
        // CSDFunctionTable * iSine = [[CSDFunctionTable alloc] initWithType:kGenSine UsingSize:iFTableSize];
        
        //float partialStrengths[] = {1.0f, 0.5f, 1.0f};
        //CSDParamArray * partialStrengthParamArray = [CSDParamArray paramArrayFromFloats:partialStrengths count:3];
//        
//        CSDParamArray * partialStrengthParamArray = [CSDParamArray paramArrayFromParams:
//                                                     [CSDParamConstant paramWithFloat:1.0f],
//                                                     [CSDParamConstant paramWithFloat:0.5f],
//                                                     [CSDParamConstant paramWithFloat:1.0f], nil];
//        
//        CSDSineTable * sineTable = [[CSDSineTable alloc] initWithTableSize:4096 PartialStrengths:partialStrengthParamArray];
//        [self addFunctionTable:sineTable];
//        
//        CSDOscillator * myOscillator = [[CSDOscillator alloc] 
//                                        initWithAmplitude:[CSDParamConstant paramWithFloat:0.12]
//                                        Frequency:[CSDParamConstant paramWithPValue:kFrequencyArg]
//                                        FunctionTable:sineTable];
//        [self addOpcode:myOscillator];
//        
//        CSDReverb * reverb = [[CSDReverb alloc] initWithInputLeft:[myOscillator output] 
//                                                       InputRight:[myOscillator output] 
//                                                    FeedbackLevel:[CSDParamConstant paramWithFloat:0.85f] 
//                                                  CutoffFrequency:[CSDParamConstant paramWithInt:12000]];
//        
//        [self addOpcode:reverb];
//        CSDOutputStereo * stereoOutput = [[CSDOutputStereo alloc] initWithInputLeft:[reverb outputLeft] 
//                                                                         InputRight:[reverb outputRight]]; 
//        [self addOpcode:stereoOutput];
    }
    return self;
}

-(void) playNoteForDuration:(float)dur Frequency:(float)freq {
//    [self playNote:[NSDictionary dictionaryWithObjectsAndKeys:
//                    [NSNumber numberWithFloat:dur],  [NSNumber numberWithInt:kDurationArg],
//                    [NSNumber numberWithFloat:freq], [NSNumber numberWithInt:kFrequencyArg], nil]];
    
}

@end
