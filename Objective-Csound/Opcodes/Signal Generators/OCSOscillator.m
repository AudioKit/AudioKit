//
//  OCSOscillator.m
//
//  Created by Aurelius Prochazka on 4/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOscillator.h"

@interface OCSOscillator () {
    OCSParam *amp;
    OCSParam *freq;
    OCSConstantParam *phs;
    OCSFTable *f;
    
    
    OCSParam *audio;
    OCSControlParam *control;
    OCSParam *output;
}
@end

@implementation OCSOscillator 

@synthesize audio;
@synthesize control;
@synthesize output;

- (id)initWithFTable:(OCSFTable *)fTable
           frequency:(OCSParam *)frequency
           amplitude:(OCSParam *)amplitude 
               phase:(OCSConstantParam *)initialPhase;
{
    self = [super init];
    if (self) {
        audio   = [OCSParam paramWithString:[self opcodeName]];
        control = [OCSControlParam paramWithString:[self opcodeName]];
        output  =  audio;
        amp  = amplitude;
        freq = frequency;
        f    = fTable;
        phs  = initialPhase;
    }
    return self; 
}

- (id)initWithFTable:(OCSFTable *)fTable
           frequency:(OCSParam *)frequency
           amplitude:(OCSParam *)amplitude;
{
    return [self initWithFTable:fTable
                      frequency:frequency
                      amplitude:amplitude 
                          phase:[OCSConstantParam paramWithInt:0]];
}

- (void)setControl:(OCSControlParam *)p {
    control = p;
    output = control;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat: 
            @"%@ oscili %@, %@, %@, %@", 
            output, amp, freq, f, phs];
}

/// Gives the CSD string for the output parameter.  
- (NSString *)description {
    return [output parameterString];
}



@end
