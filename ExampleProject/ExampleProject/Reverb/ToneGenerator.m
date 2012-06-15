//
//  ToneGenerator.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ToneGenerator.h"

typedef enum
{
    kPValuePitchTag=4,
}kPValueTag;

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
                                        initWithAmplitude:[CSDParamConstant paramWithFloat:0.4]
                                                Frequency:[CSDParamConstant paramWithPValue:kPValuePitchTag]
                                            FunctionTable:sineTable];
        [myOscillator setOutput:auxilliaryOutput];
        [self addOpcode:myOscillator];

        CSDOutputStereo * stereoOutput = 
        [[CSDOutputStereo alloc] initWithInputLeft:[myOscillator output] 
                                        InputRight:[myOscillator output]]; 
        [self addOpcode:stereoOutput];
        
//        auxilliaryOutput =
//        CSDParam * cumulativeReverb = [CSDParam paramWithFormat:@"%@ + %@", [fx input], [myOscillator output]];
//        CSDAssignment * reverbSend = [[CSDAssignment alloc] initWithInput:cumulativeReverb];
//        [reverbSend setOutput:[fx input]];
//        [self addOpcode:reverbSend];
    }
    return self;
}

-(void) playNoteForDuration:(float)dur Pitch:(float)pitch {
    int instrumentNumber = [[orchestra instruments] indexOfObject:self] + 1;
    NSString * note = [NSString stringWithFormat:@"%0.2f %0.2f", dur, pitch];
    [[CSDManager sharedCSDManager] playNote:note OnInstrument:instrumentNumber];
}

@end
