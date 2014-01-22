//
//  AKMoogVCF.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's moogvcf2:
//  http://www.csounds.com/manual/html/moogvcf2.html
//

#import "AKMoogVCF.h"

@interface AKMoogVCF () {
    AKAudio *asig;
    AKParameter *xfco;
    AKParameter *xres;
}
@end

@implementation AKMoogVCF

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                    cutoffFrequency:(AKParameter *)cutoffFrequency
                          resonance:(AKParameter *)resonance
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = audioSource;
        xfco = cutoffFrequency;
        xres = resonance;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ moogvcf2 %@, %@, %@",
            self, asig, xfco, xres];
}

@end