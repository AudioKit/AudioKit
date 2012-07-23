//
//  UDOPitchShifter.m
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 6/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOCsGrainPitchShifter.h"

@interface UDOCsGrainPitchShifter () {
    OCSParameter *leftOutput;
    OCSParameter *rightOutput;
    OCSParameter *inL;
    OCSParameter *inR;
    OCSControl *pitch;
    OCSControl *offset;
    OCSControl *feedback;
}
@end

@implementation UDOCsGrainPitchShifter

@synthesize leftOutput;
@synthesize rightOutput;

- (id)initWithLeftInput:(OCSParameter *)leftInput
             rightInput:(OCSParameter *)rightInput
              basePitch:(OCSControl *)basePitch
        offsetFrequency:(OCSControl *)fineTuningOffsetFrequency
          feedbackLevel:(OCSControl *)feedbackLevel;
{
    self = [super init];
    if (self) {
        leftOutput  = [OCSParameter parameterWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"L"]];
        rightOutput = [OCSParameter parameterWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"R"]];
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
            leftOutput, rightOutput, inL, inR, pitch, offset, feedback];
}

@end
