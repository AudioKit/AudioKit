//
//  AKFlatFrequencyResponseReverb.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 8/3/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's alpass:
//  http://www.csounds.com/manual/html/alpass.html
//

#import "AKFlatFrequencyResponseReverb.h"

@implementation AKFlatFrequencyResponseReverb
{
    AKAudio *asig;
    AKControl *krvt;
    AKConstant *ilpt;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                  reverberationTime:(AKControl *)reverberationTime
                           loopTime:(AKConstant *)loopTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = audioSource;
        krvt = reverberationTime;
        ilpt = loopTime;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ alpass %@, %@, %@",
            self, asig, krvt, ilpt];
}

@end