//
//  ToneGenerator.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ToneGenerator.h"

typedef enum { kDurationArg, kFrequencyArg } ExpressionToneGeneratorArguments;

@implementation ToneGenerator
@synthesize auxilliaryOutput;

-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra
{
    self = [super initWithOrchestra:newOrchestra];
    if (self) {                      

        auxilliaryOutput = [CSDParam paramWithString:@"OscillatorOutput"];
        CSDSineTable * sineTable = [[CSDSineTable alloc] init];
        [self addFunctionTable:sineTable];
        
        CSDOscillator * myOscillator = [[CSDOscillator alloc] 
                                        initWithAmplitude:[CSDParamConstant paramWithFloat:0.1]
                                                Frequency:[CSDParamConstant paramWithPValue:kFrequencyArg]
                                            FunctionTable:sineTable];
        [myOscillator setOutput:auxilliaryOutput];
        [self addOpcode:myOscillator];

        CSDOutputStereo * stereoOutput = 
        [[CSDOutputStereo alloc] initWithInputLeft:[myOscillator output] 
                                        InputRight:[myOscillator output]]; 
        [self addOpcode:stereoOutput];

    }
    return self;
}

-(void) playNoteForDuration:(float)dur Frequency:(float)freq {
    [self playNote:[NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithFloat:dur],  [NSNumber numberWithInt:kDurationArg],
                    [NSNumber numberWithFloat:freq], [NSNumber numberWithInt:kFrequencyArg],nil]];
}

@end
