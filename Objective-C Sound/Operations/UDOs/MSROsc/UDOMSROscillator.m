//
//  UDOMSROscillator.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/24/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOMSROscillator.h"

@interface UDOMSROscillator () {
    OCSConstant *amplitude;
    OCSControl *frequency;
    OscillatorType type;
}
@end

@implementation UDOMSROscillator

- (id)initWithType:(OscillatorType)oscillatorType
         frequency:(OCSControl *)pitchOrFrequency
         amplitude:(OCSConstant *)maxAmplitude;

{
    self = [super initWithString:[self operationName]];
    if (self) {
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
            self, amplitude, frequency, type];
}

@end
