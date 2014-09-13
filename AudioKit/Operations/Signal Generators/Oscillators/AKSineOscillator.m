//
//  AKSineOscillator.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's oscils:
//  http://www.csounds.com/manual/html/oscils.html
//

#import "AKSineOscillator.h"

@implementation AKSineOscillator
{
    AKConstant *icps;
    AKConstant *iamp;
    AKConstant *iphs;
}

- (instancetype)initWithFrequency:(AKConstant *)frequency
                        amplitude:(AKConstant *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        icps = frequency;
        iamp = amplitude;
        iphs = akp(0);
    }
    return self;
}

- (void)setOptionalPhase:(AKConstant *)phase {
	iphs = phase;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ oscils %@, %@, %@",
            self, iamp, icps, iphs];
}

@end