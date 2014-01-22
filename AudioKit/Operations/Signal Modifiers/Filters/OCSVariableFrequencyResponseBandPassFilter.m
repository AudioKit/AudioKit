//
//  OCSVariableFrequencyResponseBandPassFilter.m
//  Objective-C Sound
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/27/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's resonz:
//  http://www.csounds.com/manual/html/resonz.html
//

#import "OCSVariableFrequencyResponseBandPassFilter.h"

@interface OCSVariableFrequencyResponseBandPassFilter () {
    OCSAudio *asig;
    OCSControl *kcf;
    OCSControl *kbw;
}
@end

@implementation OCSVariableFrequencyResponseBandPassFilter

- (instancetype)initWithAudioSource:(OCSAudio *)audioSource
                    cutoffFrequency:(OCSControl *)cutoffFrequency
                          bandwidth:(OCSControl *)bandwidth
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = audioSource;
        kcf = cutoffFrequency;
        kbw = bandwidth;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ resonz %@, %@, %@",
            self, asig, kcf, kbw];
}

@end