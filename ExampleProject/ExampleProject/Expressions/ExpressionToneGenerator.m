//
//  ExpressionToneGenerator.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/10/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ExpressionToneGenerator.h"

@implementation ExpressionToneGenerator
@synthesize frequency;

-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra
{
    self = [super initWithOrchestra:newOrchestra];
    if (self) {                  
        // INPUTS AND CONTROLS =================================================
        
        frequency  = [[CSDProperty alloc] init];
        [frequency  setOutput:[CSDParamControl paramWithString:@"Frequency"]]; 
        
        // INSTRUMENT DEFINITION ===============================================
        
        CSDSineTable * sineTable = [[CSDSineTable alloc] init];
        [self addFunctionTable:sineTable];
        
        CSDSineTable * vibratoSine = [[CSDSineTable alloc] init];
        [self addFunctionTable:vibratoSine];
        
        CSDOscillator * myVibratoOscillator = 
        [[CSDOscillator alloc] initWithAmplitude:[CSDParamConstant paramWithInt:40]
                                       Frequency:[CSDParamConstant paramWithInt:6] 
                                   FunctionTable:vibratoSine
                                       isControl:YES];
        [self addOpcode:myVibratoOscillator];
        
        float vibratoScale = 2.0f;
        int vibratoOffset = 320;
        CSDParamControl * vibrato = 
        [CSDParamControl paramWithFormat:@"%d + (%f * %@)", vibratoOffset, vibratoScale, myVibratoOscillator];
        
        CSDParamConstant * amplitudeOffset = [CSDParamConstant paramWithFloat:0.1];
        
        CSDLine * amplitudeRamp = 
        [[CSDLine alloc] initWithStartingValue:[CSDParamConstant paramWithFloat:0.0f] Duration:duration
                                   TargetValue:[CSDParamConstant paramWithFloat:0.2]];
        [self addOpcode:amplitudeRamp];
        
        CSDParamControl * totalAmplitude = 
        [CSDParamControl paramWithFormat:@"%@ + %@", amplitudeRamp, amplitudeOffset];                    
        CSDOscillator * myOscillator = [[CSDOscillator alloc] 
                                        initWithAmplitude:totalAmplitude
                                                Frequency:vibrato
                                            FunctionTable:sineTable];
        [self addOpcode:myOscillator];
        
        // AUDIO OUTPUT ========================================================
        
        CSDOutputStereo * stereoOutput = 
        [[CSDOutputStereo alloc] initWithMonoInput:[myOscillator output]]; 
        [self addOpcode:stereoOutput];
    }
    return self;
}
-(void) playNoteForDuration:(float)dur Frequency:(float)freq {
    frequency.value = freq;
    [self playNoteWithDuration:dur];
}

@end
