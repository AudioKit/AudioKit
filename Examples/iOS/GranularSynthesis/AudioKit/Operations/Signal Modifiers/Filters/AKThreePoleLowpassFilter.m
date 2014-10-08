//
//  AKThreePoleLowpassFilter.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's lpf18:
//  http://www.csounds.com/manual/html/lpf18.html
//

#import "AKThreePoleLowpassFilter.h"

@implementation AKThreePoleLowpassFilter
{
    AKAudio *asig;
    AKControl *kdist;
    AKControl *kfco;
    AKControl *kres;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                         distortion:(AKControl *)distortion
                    cutoffFrequency:(AKControl *)cutoffFrequency
                          resonance:(AKControl *)resonance
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = audioSource;
        kdist = distortion;
        kfco = cutoffFrequency;
        kres = resonance;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ lpf18 %@, %@, %@, %@",
            self, asig, kfco, kres, kdist];
}

@end