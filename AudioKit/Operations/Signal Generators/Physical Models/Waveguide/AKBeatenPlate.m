//
//  AKBeatenPlate.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/25/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's wguide2:
//  http://www.csounds.com/manual/html/wguide2.html
//

#import "AKBeatenPlate.h"

@interface AKBeatenPlate () {
    AKAudio *asig;
    AKParameter *xfreq1;
    AKParameter *xfreq2;
    AKControl *kcutoff1;
    AKControl *kcutoff2;
    AKControl *kfeedback1;
    AKControl *kfeedback2;
}
@end

@implementation AKBeatenPlate

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                         frequency1:(AKParameter *)frequency1
                         frequency2:(AKParameter *)frequency2
                   cutoffFrequency1:(AKControl *)cutoffFrequency1
                   cutoffFrequency2:(AKControl *)cutoffFrequency2
                          feedback1:(AKControl *)feedback1
                          feedback2:(AKControl *)feedback2
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = audioSource;
        xfreq1 = frequency1;
        xfreq2 = frequency2;
        kcutoff1 = cutoffFrequency1;
        kcutoff2 = cutoffFrequency2;
        kfeedback1 = feedback1;
        kfeedback2 = feedback2;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ wguide2 %@, %@, %@, %@, %@, %@, %@",
            self, asig, xfreq1, xfreq2, kcutoff1, kcutoff2, kfeedback1, kfeedback2];
}

@end