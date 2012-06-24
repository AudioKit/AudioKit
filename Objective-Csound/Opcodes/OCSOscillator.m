//
//  OCSOscillator.m
//
//  Created by Aurelius Prochazka on 4/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOscillator.h"

@implementation OCSOscillator 

@synthesize audio;
@synthesize control;
@synthesize output;

- (id)initWithAmplitude:(OCSParam *)amp 
              Frequency:(OCSParam *)freq 
          FunctionTable:(OCSFunctionTable *)f
{
    self = [super init];
    if (self) {
        audio   = [OCSParam paramWithString:[self opcodeName]];
        control = [OCSParamControl paramWithString:[self opcodeName]];
        output  =  audio;
        amplitude = amp;
        frequency = freq;
        functionTable = f;
    }
    return self; 
}


- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ oscili %@, %@, %@\n",
            output, amplitude, frequency, functionTable];
}

- (NSString *)description {
    return [output parameterString];
}



@end
