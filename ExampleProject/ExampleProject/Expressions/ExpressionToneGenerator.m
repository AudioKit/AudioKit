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

-(id) initWithOrchestra:(OCSOrchestra *)orch
{
    self = [super initWithOrchestra:orch];
    if (self) {                  
        // INPUTS AND CONTROLS =================================================
        
        frequency  = [[OCSProperty alloc] init];
        [frequency  setOutput:[OCSParamControl paramWithString:@"Frequency"]]; 
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSSineTable * sineTable = [[OCSSineTable alloc] init];
        [self addFunctionTable:sineTable];
        
        OCSSineTable * vibratoSine = [[OCSSineTable alloc] init];
        [self addFunctionTable:vibratoSine];
        
        OCSOscillator * myVibratoOscillator = 
        [[OCSOscillator alloc] initWithAmplitude:[OCSParamConstant paramWithInt:40]
                                       Frequency:[OCSParamConstant paramWithInt:6] 
                                   FunctionTable:vibratoSine
                                       isControl:YES];
        [self addOpcode:myVibratoOscillator];
        
        float vibratoScale = 2.0f;
        int vibratoOffset = 320;
        OCSParamControl * vibrato = 
        [OCSParamControl paramWithFormat:@"%d + (%f * %@)", vibratoOffset, vibratoScale, myVibratoOscillator];
        
        OCSParamConstant * amplitudeOffset = [OCSParamConstant paramWithFloat:0.1];
        
        OCSLine * amplitudeRamp = 
        [[OCSLine alloc] initWithStartingValue:[OCSParamConstant paramWithFloat:0.0f] Duration:duration
                                   TargetValue:[OCSParamConstant paramWithFloat:0.2]];
        [self addOpcode:amplitudeRamp];
        
        OCSParamControl * totalAmplitude = 
        [OCSParamControl paramWithFormat:@"%@ + %@", amplitudeRamp, amplitudeOffset];                    
        OCSOscillator * myOscillator = [[OCSOscillator alloc] 
                                        initWithAmplitude:totalAmplitude
                                                Frequency:vibrato
                                            FunctionTable:sineTable];
        [self addOpcode:myOscillator];
        
        // AUDIO OUTPUT ========================================================
        
        OCSOutputStereo * stereoOutput = 
        [[OCSOutputStereo alloc] initWithMonoInput:[myOscillator output]]; 
        [self addOpcode:stereoOutput];
    }
    return self;
}
-(void) playNoteForDuration:(float)dur Frequency:(float)freq {
    frequency.value = freq;
    [self playNoteForDuration:dur];
}

@end
