//
//  OCSPhasor.m
//  Objective-C Sound
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's phasor:
//  http://www.csounds.com/manual/html/phasor.html
//

#import "OCSPhasor.h"

@interface OCSPhasor () {
    OCSParameter *xcps;
    OCSConstant *iphs;
}
@end

@implementation OCSPhasor

- (instancetype)initWithFrequency:(OCSParameter *)frequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        xcps = frequency;
        iphs = ocsp(0);
    }
    return self;
}

- (void)setOptionalPhase:(OCSConstant *)phase {
	iphs = phase;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ phasor %@, %@",
            self, xcps, iphs];
}

@end