//
//  UDOPitchShifter.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOCsGrainPitchShifter.h"

@interface UDOCsGrainPitchShifter () {
    OCSParameter *outputLeft;
    OCSParameter *outputRight;
    OCSParameter *inL;
    OCSParameter *inR;
    OCSControl *pitch;
    OCSControl *offset;
    OCSControl *feedback;
}
@end

@implementation UDOCsGrainPitchShifter

@synthesize outputLeft;
@synthesize outputRight;

- (id)initWithLeftInput:(OCSParameter *)leftInput
             rightInput:(OCSParameter *)rightInput
              basePitch:(OCSControl *)basePitch
        offsetFrequency:(OCSControl *)fineTuningOffsetFrequency
          feedbackLevel:(OCSControl *)feedbackLevel;
{
    self = [super init];
    if (self) {
        outputLeft  = [OCSParameter parameterWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"L"]];
        outputRight = [OCSParameter parameterWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"R"]];
        inL      = leftInput;
        inR      = rightInput;
        pitch    = basePitch;
        offset   = fineTuningOffsetFrequency;
        feedback = feedbackLevel;
    }
    return self; 
}

- (NSString *) udoFile {
    return [[NSBundle mainBundle] pathForResource: @"CsGrainPitchShifter" ofType: @"udo"];
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@, %@ PitchShifter %@, %@, %@, %@, %@",
            outputLeft, outputRight, inL, inR, pitch, offset, feedback];
}

@end
