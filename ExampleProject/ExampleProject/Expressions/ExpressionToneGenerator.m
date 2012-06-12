//
//  ExpressionToneGenerator.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/10/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ExpressionToneGenerator.h"

typedef enum
{
    kPValueTagPitch=4,
}kPValueTag;

@implementation ExpressionToneGenerator

-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra
{
    self = [super initWithOrchestra:newOrchestra];
    if (self) {                                                   
        CSDSineTable * sineTable = [[CSDSineTable alloc] init];
        [self addFunctionTable:sineTable];
        
        CSDSineTable * vibratoSine = [[CSDSineTable alloc] init];
        [self addFunctionTable:vibratoSine];
        

                                      
        CSDOscillator * myVibratoOscillator = [[CSDOscillator alloc] 
                                               initWithAmplitude:[CSDParamConstant paramWithInt:40]
                                                       Frequency:[CSDParamConstant paramWithInt:6] 
                                                   FunctionTable:vibratoSine
                                                        isControl:YES];
        [self addOpcode:myVibratoOscillator];
        
        float vibratoScale = 2.0f;
        int vibratoOffset = 320;
        CSDParamControl * vibrato = [CSDParamControl paramWithFormat:@"%d + (%f * %@)", vibratoOffset, vibratoScale, myVibratoOscillator];
        
        CSDParamConstant * amplitudeOffset = [CSDParamConstant paramWithFloat:0.1];
        CSDLine * amplitudeRamp = [[CSDLine alloc] 
                                   initWithIStartingValue:[CSDParamConstant paramWithFloat:0.0f] 
                                                iDuration:[CSDParamConstant paramWithPValue:kPValueTagDuration]
                                             iTargetValue:[CSDParamConstant paramWithFloat:0.2]];
        [self addOpcode:amplitudeRamp];
        
        CSDParamControl * totalAmplitude = [CSDParamControl paramWithFormat:@"%@ + %@", amplitudeRamp, amplitudeOffset];                    
        CSDOscillator * myOscillator = [[CSDOscillator alloc] 
                                        initWithAmplitude:totalAmplitude
                                                Frequency:vibrato
                                            FunctionTable:sineTable];
                                        
        [self addOpcode:myOscillator];
        
        CSDOutputStereo * stereoOutput = 
        [[CSDOutputStereo alloc] initWithInputLeft:[myOscillator output] 
                                        InputRight:[myOscillator output]]; 
        [self addOpcode:stereoOutput];
    }
    return self;
}
-(void) playNoteForDuration:(float)dur Pitch:(float)pitch
{
    int instrumentNumber = [[orchestra instruments] indexOfObject:self] + 1;
    NSString * note = [NSString stringWithFormat:@"%0.2f %0.2f", dur, pitch];
    [[CSDManager sharedCSDManager] playNote:note OnInstrument:instrumentNumber];
}

@end
