//
//  OCSSineOscillator.m
//  Objective-C Sound
//
//  Auto-generated from database on 11/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's oscils:
//  http://www.csounds.com/manual/html/oscils.html
//

#import "OCSSineOscillator.h"

@interface OCSSineOscillator () {
    OCSConstant *icps;
    OCSConstant *iamp;
    OCSConstant *iphs;
}
@end

@implementation OCSSineOscillator

- (instancetype)initWithFrequency:(OCSConstant *)frequency
                        amplitude:(OCSConstant *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        icps = frequency;
        iamp = amplitude;
        iphs = ocsp(0);
    }
    return self;
}

- (void)setOptionalPhase:(OCSConstant *)phase {
	iphs = phase;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ oscils %@, %@, %@",
            self, iamp, icps, iphs];
}

@end