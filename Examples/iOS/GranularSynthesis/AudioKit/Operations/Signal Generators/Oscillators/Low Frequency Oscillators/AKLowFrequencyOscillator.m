//
//  AKLowFrequencyOscillator.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/4/12.
//  Modified by Aurelius Prochazka on 11/4/12 to enumerate types.
//
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's lfo:
//  http://www.csounds.com/manual/html/lfo.html
//

#import "AKLowFrequencyOscillator.h"

@implementation AKLowFrequencyOscillator
{
    AKControl *kcps;
    AKControl *kamp;
    AKConstant *itype;
}

- (instancetype)initWithFrequency:(AKControl *)frequency
                        amplitude:(AKControl *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        kcps = frequency;
        kamp = amplitude;
        itype = akpi(0);
    }
    return self;
}

- (void)setOptionalType:(LFOType)type {
	itype = akpi(type);
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ lfo %@, %@, %@",
            self, kamp, kcps, itype];
}

@end