//
//  EffectsProcessor.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "EffectsProcessor.h"

@implementation EffectsProcessor
@synthesize input;

-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra ToneGenerator:(ToneGenerator *)tg
{
    self = [super initWithOrchestra:newOrchestra];
    if (self) {                                                   
        input = [tg auxilliaryOutput];
        
        CSDReverb * reverb = [[CSDReverb alloc] initWithInputLeft:input
                                                       InputRight:input 
                                                    FeedbackLevel:[CSDParamConstant paramWithFloat:0.85f] 
                                                  CutoffFrequency:[CSDParamConstant paramWithInt:12000]];
        
        [self addOpcode:reverb];
        CSDOutputStereo * stereoOutput = [[CSDOutputStereo alloc] initWithInputLeft:[reverb outputLeft] 
                                                                         InputRight:[reverb outputRight]]; 
        [self addOpcode:stereoOutput];
        
        CSDAssignment * reverbZero = [[CSDAssignment alloc] initWithInput:[CSDParamConstant paramWithInt:0]];
        [reverbZero setOutput:input];
        [self addOpcode:reverbZero];
        
    }
    return self;
}

-(void) start {
    int instrumentNumber = [[orchestra instruments] indexOfObject:self] + 1;
    NSString * note = [NSString stringWithFormat:@"%0.2f", 10000.0f];
    [[CSDManager sharedCSDManager] playNote:note OnInstrument:instrumentNumber];
}

@end
