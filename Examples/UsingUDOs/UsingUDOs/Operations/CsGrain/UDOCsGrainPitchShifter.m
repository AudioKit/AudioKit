//
//  UDOPitchShifter.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOCSGrainPitchShifter.h"

@interface UDOCSGrainPitchShifter () {
    AKStereoAudio *inLR;
    AKControl *pitch;
    AKControl *offset;
    AKControl *feedback;
}
@end

@implementation UDOCSGrainPitchShifter

- (instancetype)initWithSourceStereoAudio:(AKStereoAudio *)sourceStereo
                                basePitch:(AKControl *)basePitch
                          offsetFrequency:(AKControl *)fineTuningOffsetFrequency
                            feedbackLevel:(AKControl *)feedbackLevel
{
    self = [super init];
    if (self) {
        inLR     = sourceStereo;
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
