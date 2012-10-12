//
//  OCSOscillator.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 4/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOscillator.h"

@interface OCSOscillator () {
    OCSParameter *amp;
    OCSParameter *freq;
    OCSConstant *phs;
    OCSFTable *f;
}
@end

@implementation OCSOscillator 


- (id)initWithFTable:(OCSFTable *)fTable
           frequency:(OCSParameter *)frequency
           amplitude:(OCSParameter *)amplitude;
{
    self = [super initWithString:[self operationName]];
    if (self) {
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
            self, amp, freq, f, phs];
}

@end
