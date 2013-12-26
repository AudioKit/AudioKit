//
//  OCSPhasor.m
//  Objective-C Sound
//
//  Auto-generated from scripts by Aurelius Prochazka on 10/11/12.
//  Copyright (c) 2012 Adam Boulanger. All rights reserved.
//

#import "OCSPhasor.h"

@interface OCSPhasor () {
    OCSParameter *freq;
    OCSConstant *phs;
}

@end

@implementation OCSPhasor

- (instancetype)initWithFrequency:(OCSParameter *)frequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        freq = frequency;
        phs  = ocsp(0);
    }
    return self;
}

- (void)setOptionalPhase:(OCSConstant *)phase {
    phs = phase;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ phasor %@, %@",
            self, freq, phs];
}

@end
