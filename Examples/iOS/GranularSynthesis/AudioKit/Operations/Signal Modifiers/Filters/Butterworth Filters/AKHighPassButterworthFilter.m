//
//  AKHighPassButterworthFilter.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's butterhp:
//  http://www.csounds.com/manual/html/butterhp.html
//

#import "AKHighPassButterworthFilter.h"

@implementation AKHighPassButterworthFilter
{
    AKAudio *asig;
    AKControl *kfreq;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                    cutoffFrequency:(AKControl *)cutoffFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = audioSource;
        kfreq = cutoffFrequency;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ butterhp %@, %@",
            self, asig, kfreq];
}

@end