//
//  OCSLowFrequencyOscillator.m
//  Objective-C Sound
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/4/12.
//  Modified by Aurelius Prochazka on 11/4/12 to enumerate types.
//
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's lfo:
//  http://www.csounds.com/manual/html/lfo.html
//

#import "OCSLowFrequencyOscillator.h"

@interface OCSLowFrequencyOscillator () {
    OCSControl *kcps;
    OCSControl *kamp;
    OCSConstant *itype;
}
@end

@implementation OCSLowFrequencyOscillator

- (instancetype)initWithFrequency:(OCSControl *)frequency
                        amplitude:(OCSControl *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        kcps = frequency;
        kamp = amplitude;
        itype = ocspi(0);
    }
    return self;
}

- (void)setOptionalType:(LFOType)type {
	itype = ocspi(type);
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ lfo %@, %@, %@",
            self, kamp, kcps, itype];
}

@end