//
//  AKEqualizerFilter.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's eqfil:
//  http://www.csounds.com/manual/html/eqfil.html
//

#import "AKEqualizerFilter.h"

@implementation AKEqualizerFilter
{
    AKAudio *ain;
    AKControl *kcf;
    AKControl *kbw;
    AKControl *kgain;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                    centerFrequency:(AKControl *)centerFrequency
                          bandwidth:(AKControl *)bandwidth
                               gain:(AKControl *)gain
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ain = audioSource;
        kcf = centerFrequency;
        kbw = bandwidth;
        kgain = gain;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ eqfil %@, %@, %@, %@",
            self, ain, kcf, kbw, kgain];
}

@end