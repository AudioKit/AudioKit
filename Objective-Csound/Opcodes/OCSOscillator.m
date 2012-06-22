//
//  OCSOscillator.m
//
//  Created by Aurelius Prochazka on 4/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOscillator.h"

@implementation OCSOscillator 

@synthesize output;

-(id) initWithAmplitude:(OCSParam *) amp 
              Frequency:(OCSParam *) freq
          FunctionTable:(OCSFunctionTable *) f 
              isControl:(BOOL)control
{
    self = [super init];
    if (self) {
        isControl = control;
        if (isControl) {
            output = [OCSParamControl paramWithString:[self uniqueName]];
        } else {
            output = [OCSParam paramWithString:[self uniqueName]];
        }

        amplitude = amp;
        frequency = freq;
        functionTable = f;
    }
    return self; 
}

-(id) initWithAmplitude:(OCSParam *)amp 
              Frequency:(OCSParam *)freq 
          FunctionTable:(OCSFunctionTable *)f
{
    self = [super init];
    if (self) {
        output = [OCSParam paramWithString:[self uniqueName]];
        amplitude = amp;
        frequency = freq;
        functionTable = f;
    }
    return self; 
}


-(NSString *)convertToCsd {
    return [NSString stringWithFormat:
            @"%@ oscil %@, %@, %@\n",
            output, amplitude, frequency, functionTable];
}

-(NSString *) description {
    return [output parameterString];
}



@end
