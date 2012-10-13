//
//  UDOPitchShifter.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOCsGrainPitchShifter.h"

@interface UDOCsGrainPitchShifter () {
    OCSAudio *leftOutput;
    OCSAudio *rightOutput;
    OCSAudio *inL;
    OCSAudio *inR;
    OCSControl *pitch;
    OCSControl *offset;
    OCSControl *feedback;
}
@end

@implementation UDOCsGrainPitchShifter

@synthesize leftOutput;
@synthesize rightOutput;

- (id)initWithLeftInput:(OCSAudio *)leftInput
             rightInput:(OCSAudio *)rightInput
              basePitch:(OCSControl *)basePitch
        offsetFrequency:(OCSControl *)fineTuningOffsetFrequency
          feedbackLevel:(OCSControl *)feedbackLevel;
{
    self = [super init];
    if (self) {
        leftOutput  = [OCSAudio parameterWithString:[NSString stringWithFormat:@"%@%@",[self operationName], @"L"]];
        rightOutput = [OCSAudio parameterWithString:[NSString stringWithFormat:@"%@%@",[self operationName], @"R"]];
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
