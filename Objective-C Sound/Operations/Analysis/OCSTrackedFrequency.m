//
//  OCSTrackedFrequency.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 11/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSTrackedFrequency.h"

@interface OCSTrackedFrequency () {
    OCSAudio *asig;
    OCSConstant *ihopsize;
    OCSConstant *ipeaks;
}
@end

@implementation OCSTrackedFrequency

- (instancetype)initWithAudioSource:(OCSAudio *)audioSource
                         sampleSize:(OCSConstant *)hopSize
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = audioSource;
        ihopsize = hopSize;
        ipeaks = ocsp(20);
    }
    return self;
}

- (void)setOptionalSpectralPeaks:(OCSConstant *)numberOfSpectralPeaks {
	ipeaks = numberOfSpectralPeaks;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@, kUnused ptrack %@, %@, %@",
            self, asig, ihopsize, ipeaks];
}

@end



