//
//  AKSimpleWaveGuideModel.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/25/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's wguide1:
//  http://www.csounds.com/manual/html/wguide1.html
//

#import "AKSimpleWaveGuideModel.h"

@interface AKSimpleWaveGuideModel () {
    AKAudio *asig;
    AKParameter *xfreq;
    AKControl *kcutoff;
    AKControl *kfeedback;
}
@end

@implementation AKSimpleWaveGuideModel

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                          frequency:(AKParameter *)frequency
                             cutoff:(AKControl *)cutoff
                           feedback:(AKControl *)feedback
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = audioSource;
        xfreq = frequency;
        kcutoff = cutoff;
        kfeedback = feedback;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ wguide1 %@, %@, %@, %@",
            self, asig, xfreq, kcutoff, kfeedback];
}

@end