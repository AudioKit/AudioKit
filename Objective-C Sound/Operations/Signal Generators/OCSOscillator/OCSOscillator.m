//
//  OCSOscillator.m
//  Objective-C Sound
//
//  Auto-generated from database on 11/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's oscili:
//  http://www.csounds.com/manual/html/oscili.html
//

#import "OCSOscillator.h"

@interface OCSOscillator () {
    OCSFTable *ifn;
    OCSParameter *xcps;
    OCSParameter *xamp;
    OCSConstant *iphs;
}
@end

@implementation OCSOscillator

- (id)initWithFTable:(OCSFTable *)fTable
           frequency:(OCSParameter *)frequency
           amplitude:(OCSParameter *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ifn  = fTable;
        xcps = frequency;
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
            @"%@ poscil %@, %@, %@, %@",
            self, xamp, xcps, ifn, iphs];
}

@end