//
//  AKOscillatingControl.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's oscili:
//  http://www.csounds.com/manual/html/oscili.html
//

#import "AKOscillatingControl.h"

@implementation AKOscillatingControl
{
    AKFTable *ifn;
    AKControl *kcps;
    AKControl *kamp;
    AKConstant *iphs;
}

- (instancetype)initWithFTable:(AKFTable *)fTable
                     frequency:(AKControl *)frequency
                     amplitude:(AKControl *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ifn = fTable;
        kcps = frequency;
        kamp = amplitude;
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
            self, kamp, kcps, ifn, iphs];
}

@end