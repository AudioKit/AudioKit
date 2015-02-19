//
//  AKTrackedFrequency.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/12/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKTrackedFrequency.h"

@implementation AKTrackedFrequency
{
    AKAudio *asig;
    AKConstant *ihopsize;
    AKConstant *ipeaks;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                         sampleSize:(AKConstant *)hopSize
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = audioSource;
        ihopsize = hopSize;
        ipeaks = akp(20);
        self.state = @"connectable";
        self.dependencies = @[audioSource];
    }
    return self;
}

- (void)setOptionalSpectralPeaks:(AKConstant *)numberOfSpectralPeaks
{
	ipeaks = numberOfSpectralPeaks;
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@, kUnused ptrack %@, %@, %@",
            self, asig, ihopsize, ipeaks];
}

@end