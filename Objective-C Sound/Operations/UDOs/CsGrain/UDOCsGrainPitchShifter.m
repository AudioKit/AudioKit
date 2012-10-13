//
//  UDOPitchShifter.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOCsGrainPitchShifter.h"

@interface UDOCsGrainPitchShifter () {
    OCSAudio *inLR;
    OCSControl *pitch;
    OCSControl *offset;
    OCSControl *feedback;
}
@end

@implementation UDOCsGrainPitchShifter

- (id)initWithStereoInput:(OCSAudio *)stereoInput
                basePitch:(OCSControl *)basePitch
          offsetFrequency:(OCSControl *)fineTuningOffsetFrequency
            feedbackLevel:(OCSControl *)feedbackLevel
{
    self = [super init];
    if (self) {
        inLR     = stereoInput;
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
            @"%@ PitchShifter %@, %@, %@, %@",
            self, inLR, pitch, offset, feedback];
}

@end
