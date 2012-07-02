//
//  OCSReverb.m
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSReverb.h"

@interface OCSReverb () {
    OCSParam *outputLeft;
    OCSParam *outputRight;
    OCSParam *inputLeft;
    OCSParam *inputRight;
    OCSControlParam *feedback;
    OCSControlParam *cutoff;
}
@end

@implementation OCSReverb

@synthesize outputLeft;
@synthesize outputRight;

- (id)initWithLeftInput:(OCSParam *)leftInput
             rightInput:(OCSParam *)rightInput
          feedbackLevel:(OCSControlParam *)feedbackLevel
        cutoffFrequency:(OCSControlParam *)cutoffFrequency;
{
    self = [super init];
    if (self) {
        outputLeft  = [OCSParam paramWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"L"]];
        outputRight = [OCSParam paramWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"R"]];
        inputLeft   = leftInput;
        inputRight  = rightInput;
        feedback    = feedbackLevel;
        cutoff      = cutoffFrequency;
    }
    return self; 
}

- (id)initWithMonoInput:(OCSParam *)monoInput
          feedbackLevel:(OCSControlParam *)feedbackLevel
        cutoffFrequency:(OCSControlParam *)cutoffFrequency;
{
    return [self initWithLeftInput:monoInput 
                        rightInput:monoInput
                     feedbackLevel:feedbackLevel
                   cutoffFrequency:cutoffFrequency];
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@, %@ reverbsc %@, %@, %@, %@",
            outputLeft, outputRight, inputLeft, inputRight, feedback, cutoff];
}

@end
