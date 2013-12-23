//
//  OCSMoogVCF.m
//  Objective-C Sound
//
//  Auto-generated from database on 12/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's moogvcf2:
//  http://www.csounds.com/manual/html/moogvcf2.html
//

#import "OCSMoogVCF.h"

@interface OCSMoogVCF () {
    OCSAudio *asig;
    OCSParameter *xfco;
    OCSParameter *xres;
}
@end

@implementation OCSMoogVCF

- (instancetype)initWithAudioSource:(OCSAudio *)audioSource
                    cutoffFrequency:(OCSParameter *)cutoffFrequency
                          resonance:(OCSParameter *)resonance
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