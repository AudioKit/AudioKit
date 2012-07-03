//
//  OCSReverb.m
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSReverb.h"

@interface OCSReverb () {
    OCSParameter *outputLeft;
    OCSParameter *outputRight;
    OCSParameter *inputLeft;
    OCSParameter *inputRight;
    OCSControl *feedback;
    OCSControl *cutoff;
}
@end

@implementation OCSReverb

@synthesize outputLeft;
@synthesize outputRight;

- (id)initWithLeftInput:(OCSParameter *)leftInput
             rightInput:(OCSParameter *)rightInput
          feedbackLevel:(OCSControl *)feedbackLevel
        cutoffFrequency:(OCSControl *)cutoffFrequency;
{
    self = [super init];
    if (self) {
        outputLeft  = [OCSParameter parameterWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"L"]];
        outputRight = [OCSParameter parameterWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"R"]];
        inputLeft   = leftInput;
        inputRight  = rightInput;
        feedback    = feedbackLevel;
        cutoff      = cutoffFrequency;
    }
    return self; 
}

- (id)initWithMonoInput:(OCSParameter *)monoInput
          feedbackLevel:(OCSControl *)feedbackLevel
        cutoffFrequency:(OCSControl *)cutoffFrequency;
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
