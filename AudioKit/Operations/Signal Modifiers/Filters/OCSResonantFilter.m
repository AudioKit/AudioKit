//
//  OCSResonantFilter.m
//  Objective-C Sound
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's reson:
//  http://www.csounds.com/manual/html/reson.html
//

#import "OCSResonantFilter.h"

@interface OCSResonantFilter () {
    OCSAudio *asig;
    OCSControl *kcf;
    OCSControl *kbw;
}
@end

@implementation OCSResonantFilter

- (instancetype)initWithAudioSource:(OCSAudio *)audioSource
                    centerFrequency:(OCSControl *)centerFrequency
                          bandwidth:(OCSControl *)bandwidth
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