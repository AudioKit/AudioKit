//
//  AKResonantFilter.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's reson:
//  http://www.csounds.com/manual/html/reson.html
//

#import "AKResonantFilter.h"

@implementation AKResonantFilter
{
    AKAudio *asig;
    AKControl *kcf;
    AKControl *kbw;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                    centerFrequency:(AKControl *)centerFrequency
                          bandwidth:(AKControl *)bandwidth
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = audioSource;
        kcf = centerFrequency;
        kbw = bandwidth;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ reson %@, %@, %@",
            self, asig, kcf, kbw];
}

@end