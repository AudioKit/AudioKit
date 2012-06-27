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
    OCSParamConstant *phs;
    OCSFunctionTable *f;
    
    
    OCSParam *audio;
    OCSParamControl *control;
    OCSParam *output;
}
@end

@implementation OCSOscillator 

@synthesize audio;
@synthesize control;
@synthesize output;

- (id)initWithFunctionTable:(OCSFunctionTable *)functionTable
                      Phase:(OCSParamConstant *)initialPhase
                  Amplitude:(OCSParam *)amplitude 
                  Frequency:(OCSParam *)frequency;
{
    self = [super init];
    if (self) {
        audio   = [OCSParam paramWithString:[self opcodeName]];
        control = [OCSParamControl paramWithString:[self opcodeName]];
        output  =  audio;
        amp  = amplitude;
        freq = frequency;
        f    = functionTable;
        phs  = initialPhase;
    }
    return self; 
}

- (id)initWithFunctionTable:(OCSFunctionTable *)functionTable
                  Amplitude:(OCSParam *)amplitude 
                  Frequency:(OCSParam *)frequency 
{
    return [self initWithFunctionTable:functionTable
                                 Phase:[OCSParamConstant paramWithInt:0]
                             Amplitude:amplitude 
                             Frequency:frequency];
}


- (NSString *)stringForCSD {
    return [NSString stringWithFormat: 
            @"%@ oscili %@, %@, %@, %@\n", 
            output, amp, freq, f, phs];
}

- (NSString *)description {
    return [output parameterString];
}



@end
