//
//  OCSSimpleWaveGuideModel.m
//  Objective-C Sound
//
//  Auto-generated from database on 12/25/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's wguide1:
//  http://www.csounds.com/manual/html/wguide1.html
//

#import "OCSSimpleWaveGuideModel.h"

@interface OCSSimpleWaveGuideModel () {
    OCSAudio *asig;
    OCSParameter *xfreq;
    OCSControl *kcutoff;
    OCSControl *kfeedback;
}
@end

@implementation OCSSimpleWaveGuideModel 

- (instancetype)initWithAudioSource:(OCSAudio *)audioSource
                          frequency:(OCSParameter *)frequency
                             cutoff:(OCSControl *)cutoff
                           feedback:(OCSControl *)feedback
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
            self, asig, xfreq, kcutoff, kfeedback, kfeedback];
}

@end