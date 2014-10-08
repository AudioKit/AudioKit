//
//  AKParallelCombLowPassFilterReverb.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 8/3/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's nreverb:
//  http://www.csounds.com/manual/html/nreverb.html
//

#import "AKParallelCombLowPassFilterReverb.h"

@implementation AKParallelCombLowPassFilterReverb
{
    AKAudio *asig;
    AKControl *ktime;
    AKControl *khdif;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                           duration:(AKControl *)duration
           highFrequencyDiffusivity:(AKControl *)highFrequencyDiffusivity
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = audioSource;
        ktime = duration;
        khdif = highFrequencyDiffusivity;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ nreverb %@, %@, %@",
            self, asig, ktime, khdif];
}

@end