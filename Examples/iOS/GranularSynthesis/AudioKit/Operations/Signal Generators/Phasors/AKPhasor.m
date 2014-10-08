//
//  AKPhasor.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's phasor:
//  http://www.csounds.com/manual/html/phasor.html
//

#import "AKPhasor.h"

@implementation AKPhasor
{
    AKParameter *xcps;
    AKConstant *iphs;
}

- (instancetype)initWithFrequency:(AKParameter *)frequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        xcps = frequency;
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
            self, xcps, iphs];
}

@end