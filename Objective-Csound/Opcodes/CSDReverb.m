//
//  CSDReverb.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDReverb.h"

@implementation CSDReverb

@synthesize outputLeft;
@synthesize outputRight;

-(id) initWithInputLeft:(CSDParam *) inLeft
             InputRight:(CSDParam *) inRight
          FeedbackLevel:(CSDParamControl *) feedback
        CutoffFrequency:(CSDParamControl *) cutoff 
{
    self = [super init];
    if (self) {
        outputLeft  = [CSDParam paramWithString:[NSString stringWithFormat:@"%@%@",[self uniqueName], @"L"]];
        outputRight = [CSDParam paramWithString:[NSString stringWithFormat:@"%@%@",[self uniqueName], @"R"]];
        inputLeft  = inLeft;
        inputRight = inRight;
        feedbackLevel = feedback;
        cutoffFrequency = cutoff;
    }
    return self; 
}

-(NSString *)convertToCsd
{
    return [NSString stringWithFormat:
            @"%@, %@ reverbsc %@, %@, %@, %@\n",
            [outputLeft      parameterString],
            [outputRight     parameterString],
            [feedbackLevel   parameterString],  
            [cutoffFrequency parameterString]];
}



@end
