//
//  OCSOscillator.m
//  Objective-Csound
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
    
    
    OCSParameter *audio;
    OCSControl *control;
    OCSParameter *output;
}
@end

@implementation OCSOscillator 

@synthesize audio;
@synthesize control;
@synthesize output;

- (id)initWithFTable:(OCSFTable *)fTable
           frequency:(OCSParameter *)frequency
           amplitude:(OCSParameter *)amplitude 
               phase:(OCSConstant *)initialPhase;
{
    self = [super init];
    if (self) {
        audio   = [OCSParameter parameterWithString:[self opcodeName]];
        control = [OCSControl parameterWithString:[self opcodeName]];
        output  =  audio;
        amp  = amplitude;
        freq = frequency;
        f    = fTable;
        phs  = initialPhase;
    }
    return self; 
}

- (id)initWithFTable:(OCSFTable *)fTable
           frequency:(OCSParameter *)frequency
           amplitude:(OCSParameter *)amplitude;
{
    return [self initWithFTable:fTable
                      frequency:frequency
                      amplitude:amplitude 
                          phase:[OCSConstant parameterWithInt:0]];
}

- (void)setControl:(OCSControl *)p {
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
