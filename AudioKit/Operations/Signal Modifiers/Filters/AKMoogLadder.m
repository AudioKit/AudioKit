//
//  AKMoogLadder.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's moogladder:
//  http://www.csounds.com/manual/html/moogladder.html
//

#import "AKMoogLadder.h"

@implementation AKMoogLadder
{
    AKAudio *ain;
    AKControl *kcf;
    AKControl *kres;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                    cutoffFrequency:(AKControl *)cutoffFrequency
                          resonance:(AKControl *)resonance
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ain = audioSource;
        kcf = cutoffFrequency;
        kres = resonance;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ moogladder %@, %@, %@",
            self, ain, kcf, kres];
}

@end