//
//  AKBandRejectButterworthFilter.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's butterbr:
//  http://www.csounds.com/manual/html/butterbr.html
//

#import "AKBandRejectButterworthFilter.h"

@implementation AKBandRejectButterworthFilter
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
            @"%@ butterbr %@, %@, %@",
            self, asig, kfreq, kband];
}

@end