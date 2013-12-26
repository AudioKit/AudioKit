//
//  OCSBeatenPlate.m
//  Objective-C Sound
//
//  Auto-generated from database on 12/25/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's wguide2:
//  http://www.csounds.com/manual/html/wguide2.html
//

#import "OCSBeatenPlate.h"

@interface OCSBeatenPlate () {
    OCSAudio *asig;
    OCSParameter *xfreq1;
    OCSParameter *xfreq2;
    OCSControl *kcutoff1;
    OCSControl *kcutoff2;
    OCSControl *kfeedback1;
    OCSControl *kfeedback2;
}
@end

@implementation OCSBeatenPlate

- (instancetype)initWithAudioSource:(OCSAudio *)audioSource
                         frequency1:(OCSParameter *)frequency1
                         frequency2:(OCSParameter *)frequency2
                   cutoffFrequency1:(OCSControl *)cutoffFrequency1
                   cutoffFrequency2:(OCSControl *)cutoffFrequency2
                          feedback1:(OCSControl *)feedback1
                          feedback2:(OCSControl *)feedback2
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