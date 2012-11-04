//
//  OCSThreePoleLowpassFilter.m
//  Objective-C Sound
//
//  Auto-generated from database on 11/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's lpf18:
//  http://www.csounds.com/manual/html/lpf18.html
//

#import "OCSThreePoleLowpassFilter.h"

@interface OCSThreePoleLowpassFilter () {
    OCSAudio *asig;
    OCSControl *kdist;
    OCSControl *kfco;
    OCSControl *kres;
}
@end

@implementation OCSThreePoleLowpassFilter

- (id)initWithSourceSignal:(OCSAudio *)sourceSignal
                distortion:(OCSControl *)distortion
           cutoffFrequency:(OCSControl *)cutoffFrequency
                 resonance:(OCSControl *)resonance
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = sourceSignal;
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