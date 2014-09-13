//
//  AKPhasingControl.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's phasor:
//  http://www.csounds.com/manual/html/phasor.html
//

#import "AKPhasingControl.h"

@implementation AKPhasingControl
{
    AKControl *kcps;
    AKConstant *iphs;
}

- (instancetype)initWithFrequency:(AKControl *)frequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        kcps = frequency;
        iphs = akp(0);
    }
    return self;
}

- (void)setOptionalPhase:(AKConstant *)phase {
	iphs = phase;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ phasor %@, %@",
            self, kcps, iphs];
}

@end