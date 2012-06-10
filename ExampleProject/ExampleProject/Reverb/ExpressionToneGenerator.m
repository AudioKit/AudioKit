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
        
        CSDOscillator * myOscillator = [[CSDOscillator alloc] 
                                        initWithAmplitude:[CSDParamConstant paramWithFloat:0.4]
                                        Pitch:[CSDParamConstant paramWithPValue:kPValueTagPitch]
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
