//
//  AudioFilePlayer.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AudioFilePlayer.h"

typedef enum { kDurationArg } AudioFilePlayerArguments;


@implementation AudioFilePlayer


-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra {
    self = [super initWithOrchestra:newOrchestra];
    if (self) {
        NSString * file = [[NSBundle mainBundle] pathForResource:@"hellorcb" ofType:@"aif"];
        CSDSoundFileTable * fileTable = [[CSDSoundFileTable alloc] initWithFilename:file];
        [self addFunctionTable:fileTable];
        
        CSDLoopingOscillator * trigger = [[CSDLoopingOscillator alloc] initWithSoundFileTable:fileTable];
        [self addOpcode:trigger];
        
        CSDReverb * reverb = [[CSDReverb alloc] initWithInputLeft:[trigger output1] 
                                                       InputRight:[trigger output1] 
                                                    FeedbackLevel:[CSDParamConstant paramWithFloat:0.85f] 
                                                  CutoffFrequency:[CSDParamConstant paramWithInt:12000]];
        
        [self addOpcode:reverb];
        CSDOutputStereo * stereoOutput = [[CSDOutputStereo alloc] initWithInputLeft:[reverb outputLeft] 
                                                                         InputRight:[reverb outputRight]]; 
        [self addOpcode:stereoOutput];
    }
    return self;
}

-(void) play {
    [self playNote:[NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithFloat:3.0],  [NSNumber numberWithInt:kDurationArg], nil]];
    
}

@end
