//
//  OCSReverb.m
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSReverb.h"

@interface OCSReverb () {
    OCSParameter *leftOutput;
    OCSParameter *rightOutput;
    OCSParameter *inputLeft;
    OCSParameter *inputRight;
    OCSControl *feedback;
    OCSControl *cutoff;
}
@end

@implementation OCSReverb

@synthesize leftOutput;
@synthesize rightOutput;

- (id)initWithLeftInput:(OCSParameter *)leftInput
             rightInput:(OCSParameter *)rightInput
          feedbackLevel:(OCSControl *)feedbackLevel
        cutoffFrequency:(OCSControl *)cutoffFrequency;
{
    self = [super init];
    if (self) {
        leftOutput  = [OCSParameter parameterWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"L"]];
        rightOutput = [OCSParameter parameterWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"R"]];
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
            leftOutput, rightOutput, inputLeft, inputRight, feedback, cutoff];
}

@end
