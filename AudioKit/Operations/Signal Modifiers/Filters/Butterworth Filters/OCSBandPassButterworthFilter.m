//
//  OCSBandPassButterworthFilter.m
//  Objective-C Sound
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's butterbp:
//  http://www.csounds.com/manual/html/butterbp.html
//

#import "OCSBandPassButterworthFilter.h"

@interface OCSBandPassButterworthFilter () {
    OCSAudio *asig;
    OCSControl *kfreq;
    OCSControl *kband;
}
@end

@implementation OCSBandPassButterworthFilter

- (instancetype)initWithAudioSource:(OCSAudio *)audioSource
                    centerFrequency:(OCSControl *)centerFrequency
                          bandwidth:(OCSControl *)bandwidth
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