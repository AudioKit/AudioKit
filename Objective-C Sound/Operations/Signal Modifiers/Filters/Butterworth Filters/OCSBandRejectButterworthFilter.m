//
//  OCSBandRejectButterworthFilter.m
//  Objective-C Sound
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's butterbr:
//  http://www.csounds.com/manual/html/butterbr.html
//

#import "OCSBandRejectButterworthFilter.h"

@interface OCSBandRejectButterworthFilter () {
    OCSAudio *asig;
    OCSControl *kfreq;
    OCSControl *kband;
}
@end

@implementation OCSBandRejectButterworthFilter

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
            @"%@ butterbr %@, %@, %@",
            self, asig, kfreq, kband];
}

@end