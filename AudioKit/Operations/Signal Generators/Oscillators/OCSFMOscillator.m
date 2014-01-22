//
//  OCSFMOscillator.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's foscili:
//  http://www.csounds.com/manual/html/foscili.html
//

#import "OCSFMOscillator.h"

@interface OCSFMOscillator () {
    OCSFTable *ifn;
    OCSControl *kcps;
    OCSParameter *xcar;
    OCSParameter *xmod;
    OCSControl *kndx;
    OCSParameter *xamp;
    OCSConstant *iphs;
}
@end

@implementation OCSFMOscillator

- (instancetype)initWithFTable:(OCSFTable *)fTable
                 baseFrequency:(OCSControl *)baseFrequency
             carrierMultiplier:(OCSParameter *)carrierMultiplier
          modulatingMultiplier:(OCSParameter *)modulatingMultiplier
               modulationIndex:(OCSControl *)modulationIndex
                     amplitude:(OCSParameter *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ifn = fTable;
        kcps = baseFrequency;
        xcar = carrierMultiplier;
        xmod = modulatingMultiplier;
        kndx = modulationIndex;
        xamp = amplitude;
        
        iphs = ocsp(0);
        
    }
    return self;
}

- (void)setOptionalPhase:(OCSConstant *)phase {
	iphs = phase;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ foscili %@, %@, %@, %@, %@, %@, %@",
            self, xamp, kcps, xcar, xmod, kndx, ifn, iphs];
}

@end