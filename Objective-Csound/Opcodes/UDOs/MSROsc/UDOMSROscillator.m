//
//  UDOMSROscillator.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/24/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOMSROscillator.h"

@interface UDOMSROscillator () {
    OCSParam *output;
    OCSParamConstant *amplitude;
    OCSParamConstant *frequency;
    OscillatorType type;
}
@end

@implementation UDOMSROscillator

@synthesize output;

- (id)initWithAmplitude:(OCSParamConstant *)maxAmplitude 
              Frequency:(OCSParamConstant *)pitchOrFrequency
                   Type:(OscillatorType)oscillatorType
{
    self = [super init];
    if (self) {
        output = [OCSParam paramWithString:[self opcodeName]];
        amplitude = maxAmplitude;
        frequency = pitchOrFrequency;
        type = oscillatorType;
    }
    return self; 
}

- (NSString *) udoFile {
    return [[NSBundle mainBundle] pathForResource: @"msrOsc" ofType: @"udo"];
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ msrosc %@, %@, %i\n",
            output, amplitude, frequency, type];
}




@end
