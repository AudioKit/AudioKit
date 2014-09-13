//
//  AKOscillator.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's oscili:
//  http://www.csounds.com/manual/html/oscili.html
//

#import "AKOscillator.h"

@implementation AKOscillator
{
    AKFTable *ifn;
    AKParameter *xcps;
    AKParameter *xamp;
    AKConstant *iphs;
}

- (instancetype)initWithFTable:(AKFTable *)fTable
                     frequency:(AKParameter *)frequency
                     amplitude:(AKParameter *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ifn  = fTable;
        xcps = frequency;
        xamp = amplitude;
        iphs = akp(0);
    }
    return self;
}

- (void)setOptionalPhase:(AKConstant *)phase {
	iphs = phase;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ poscil %@, %@, %@, %@",
            self, xamp, xcps, ifn, iphs];
}

@end