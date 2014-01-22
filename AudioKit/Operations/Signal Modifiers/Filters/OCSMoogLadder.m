//
//  OCSMoogLadder.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's moogladder:
//  http://www.csounds.com/manual/html/moogladder.html
//

#import "OCSMoogLadder.h"

@interface OCSMoogLadder () {
    OCSAudio *ain;
    OCSControl *kcf;
    OCSControl *kres;
}
@end

@implementation OCSMoogLadder

- (instancetype)initWithAudioSource:(OCSAudio *)audioSource
                    cutoffFrequency:(OCSControl *)cutoffFrequency
                          resonance:(OCSControl *)resonance
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