//
//  UDOPitchShifter.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOCsGrainPitchShifter.h"

@interface UDOCsGrainPitchShifter () {
    OCSParam *outputLeft;
    OCSParam *outputRight;
    OCSParam *inL;
    OCSParam *inR;
    OCSControlParam *pitch;
    OCSControlParam *offset;
    OCSControlParam *feedback;
}
@end

@implementation UDOCsGrainPitchShifter

@synthesize outputLeft;
@synthesize outputRight;

- (id)initWithLeftInput:(OCSParam *)leftInput
             rightInput:(OCSParam *)rightInput
              basePitch:(OCSControlParam *)basePitch
        offsetFrequency:(OCSControlParam *)fineTuningOffsetFrequency
          feedbackLevel:(OCSControlParam *)feedbackLevel;
{
    self = [super init];
    if (self) {
        outputLeft  = [OCSParam paramWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"L"]];
        outputRight = [OCSParam paramWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"R"]];
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
