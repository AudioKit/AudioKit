//
//  UDOMSROscillator.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/24/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOMSROscillator.h"

@implementation UDOMSROscillator

@synthesize output;

- (id)initWithAmplitude:(OCSParamConstant *)amp 
              Frequency:(OCSParamConstant *)cps 
                   Type:(OscillatorType)t 
{
    self = [super init];
    if (self) {
        output = [OCSParam paramWithString:[self opcodeName]];
        amplitude = amp;
        frequency = cps;
        type = t;
        
//        [[self file] writeToFile:myUDOFile 
//                 atomically:YES  
//                   encoding:NSStringEncodingConversionAllowLossy 
//                      error:nil];
    }
    return self; 
}

- (NSString *) file {
    return [[NSBundle mainBundle] pathForResource: @"msrOsc" ofType: @"udo"];
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ msrosc %@, %@, %i\n",
            output, amplitude, frequency, type];
}




@end
