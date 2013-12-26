//
//  OCSHighPassButterworthFilter.m
//  Objective-C Sound
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's butterhp:
//  http://www.csounds.com/manual/html/butterhp.html
//

#import "OCSHighPassButterworthFilter.h"

@interface OCSHighPassButterworthFilter () {
    OCSAudio *asig;
    OCSControl *kfreq;
}
@end

@implementation OCSHighPassButterworthFilter

- (instancetype)initWithAudioSource:(OCSAudio *)audioSource
                    cutoffFrequency:(OCSControl *)cutoffFrequency
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