//
//  AKFMOscillator.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's foscili:
//  http://www.csounds.com/manual/html/foscili.html
//

#import "AKFMOscillator.h"

@implementation AKFMOscillator
{
    AKFTable *ifn;
    AKControl *kcps;
    AKParameter *xcar;
    AKParameter *xmod;
    AKControl *kndx;
    AKParameter *xamp;
    AKConstant *iphs;
}

- (instancetype)initWithFTable:(AKFTable *)fTable
                 baseFrequency:(AKControl *)baseFrequency
             carrierMultiplier:(AKParameter *)carrierMultiplier
          modulatingMultiplier:(AKParameter *)modulatingMultiplier
               modulationIndex:(AKControl *)modulationIndex
                     amplitude:(AKParameter *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ifn = fTable;
        kcps = baseFrequency;
        xcar = carrierMultiplier;
        xmod = modulatingMultiplier;
        kndx = modulationIndex;
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
            @"%@ foscili %@, %@, %@, %@, %@, %@, %@",
            self, xamp, kcps, xcar, xmod, kndx, ifn, iphs];
}

@end