//
//  AKBandPassButterworthFilter.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's butterbp:
//  http://www.csounds.com/manual/html/butterbp.html
//

#import "AKBandPassButterworthFilter.h"

@implementation AKBandPassButterworthFilter
{
    AKAudio *asig;
    AKControl *kfreq;
    AKControl *kband;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                    centerFrequency:(AKControl *)centerFrequency
                          bandwidth:(AKControl *)bandwidth
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = audioSource;
        kfreq = centerFrequency;
        kband = bandwidth;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ butterbp %@, %@, %@",
            self, asig, kfreq, kband];
}

@end