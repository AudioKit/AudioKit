//
//  UDOMSROscillator.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/24/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOMSROscillator.h"

@interface UDOMSROscillator () {
    OCSParameter *output;
    OCSConstant *amplitude;
    OCSConstant *frequency;
    OscillatorType type;
}
@end

@implementation UDOMSROscillator

@synthesize output;

- (id)initWithType:(OscillatorType)oscillatorType
         frequency:(OCSConstant *)pitchOrFrequency
         amplitude:(OCSConstant *)maxAmplitude;

{
    self = [super init];
    if (self) {
        output = [OCSParameter parameterWithString:[self opcodeName]];
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
            @"%@ msrosc %@, %@, %i",
            output, amplitude, frequency, type];
}




@end
