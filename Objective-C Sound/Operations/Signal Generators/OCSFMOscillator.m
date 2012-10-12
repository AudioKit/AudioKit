//
//  OCSFMOscillator.m
//  Objective-C Sound
//
//  Created by Adam Boulanger on 5/29/12.
//  Copyright (c) 2012 MIT Media Lab. All rights reserved.
//
//  Implementation of Csound's foscili:
// http://www.csounds.com/manual/html/foscili.html
//

#import "OCSFMOscillator.h"

@interface OCSFMOscillator () {
    OCSParameter *xamp;
    OCSControl *kcps;
    OCSParameter *xcar;
    OCSParameter *xmod;
    OCSControl *kndx;
    OCSFTable *ifn;
    OCSConstant *phs;
}
@end

@implementation OCSFMOscillator

- (id)initWithFTable:(OCSFTable *)fTable
       baseFrequency:(OCSControl *)baseFrequency
   carrierMultiplier:(OCSParameter *)carrierMultiplier
modulatingMultiplier:(OCSParameter *)modulatingMultiplier
     modulationIndex:(OCSControl *)modulationIndex
           amplitude:(OCSParameter *)amplitude;
{
    self = [super initWithString:[self operationName]];
    if ( self ) {
        xamp = amplitude;
        kcps = baseFrequency;
        xcar = carrierMultiplier;
        xmod = modulatingMultiplier;
        kndx = modulationIndex;
        ifn  = fTable;
        phs  = ocsp(0);
    }
    return self;
}

- (void)setPhase:(OCSConstant *)phase {
    phs = phase;
}

// Csound Prototype: ares foscili xamp, kcps, xcar, xmod, kndx, ifn (, iphs)
- (NSString *)stringForCSD
{
    return[NSString stringWithFormat:
           @"%@ foscili %@, %@, %@, %@, %@, %@, %@",
           self, xamp, kcps, xcar, xmod, kndx, ifn, phs];
}

@end
