//
//  OCSOscillatingControl.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 10/10/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOscillatingControl.h"

@interface OCSOscillatingControl () {
    OCSControl *amp;
    OCSControl *freq;
    OCSConstant *phs;
    OCSFTable *f;
    
    OCSParameter *output;
}
@end

@implementation OCSOscillatingControl

- (id)initWithFTable:(OCSFTable *)fTable
           frequency:(OCSControl *)frequency
           amplitude:(OCSControl *)amplitude;
{
    self = [super init];
    if (self) {
        output = [OCSControl parameterWithString:[self operationName]];
        amp  = amplitude;
        freq = frequency;
        f    = fTable;
        phs  = ocsp(0);
    }
    return self;
}

- (void)setPhase:(OCSConstant *)phase {
    phs = phase;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ oscili %@, %@, %@, %@",
            output, amp, freq, f, phs];
}

- (NSString *)description {
    return [output parameterString];
}


@end
