//
//  OCSReverb.m
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSReverb.h"

@implementation OCSReverb

@synthesize outputLeft;
@synthesize outputRight;

- (id)initWithMonoInput:(OCSParam *)in 
         FeedbackLevel:(OCSParamControl *) feedback
       CutoffFrequency:(OCSParamControl *) cutoff 
{
    return [self initWithInputLeft:in InputRight:in FeedbackLevel:feedback CutoffFrequency:cutoff];
}

- (id)initWithInputLeft:(OCSParam *) inLeft
            InputRight:(OCSParam *) inRight
         FeedbackLevel:(OCSParamControl *) feedback
       CutoffFrequency:(OCSParamControl *) cutoff 
{
    self = [super init];
    if (self) {
        outputLeft      = [OCSParam paramWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"L"]];
        outputRight     = [OCSParam paramWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"R"]];
        inputLeft       = inLeft;
        inputRight      = inRight;
        feedbackLevel   = feedback;
        cutoffFrequency = cutoff;
    }
    return self; 
}

- (NSString *)convertToCsd
{
    return [NSString stringWithFormat:
            @"%@, %@ reverbsc %@, %@, %@, %@\n",
            outputLeft, outputRight, inputLeft, inputRight, feedbackLevel, cutoffFrequency];
}

@end
