//
//  OCSOscillator.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
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
        ifn = fTable;
        xcps = frequency;
        xamp = amplitude;
        
        iphs = ocsp(0);
        
    }
    return self;
}

- (void)setPhase:(OCSConstant *)phase {
	iphs = phase;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ oscili %@, %@, %@, %@",
            self, xamp, xcps, ifn, iphs];
}

@end