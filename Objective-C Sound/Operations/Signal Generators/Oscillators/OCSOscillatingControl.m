//
//  OCSOscillatingControl.m
//  Objective-C Sound
//
//  Auto-generated from database on 11/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's oscili:
//  http://www.csounds.com/manual/html/oscili.html
//

#import "OCSOscillatingControl.h"

@interface OCSOscillatingControl () {
    OCSFTable *ifn;
    OCSControl *kcps;
    OCSControl *kamp;
    OCSConstant *iphs;
}
@end

@implementation OCSOscillatingControl

- (instancetype)initWithFTable:(OCSFTable *)fTable
           frequency:(OCSControl *)frequency
           amplitude:(OCSControl *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ifn = fTable;
        kcps = frequency;
        kamp = amplitude;
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
            self, kamp, kcps, ifn, iphs];
}

@end