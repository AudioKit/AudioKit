//
//  OCSWeightedMean.m
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 6/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSWeightedMean.h"

@interface OCSWeightedMean () {
    OCSParameter *in1;
    OCSParameter *in2;
    float min;
    float max;
    OCSParameter *current;

    OCSParameter *audio;
    OCSControl *control;
    OCSConstant *constant;
    OCSParameter *output;
}
@end

@implementation OCSWeightedMean


@synthesize audio;
@synthesize control;
@synthesize constant;
@synthesize output;

- (id)initWithSignal1:(OCSParameter *)signal1 
              signal2:(OCSParameter *)signal2
              balance:(OCSParameter *)balancePoint;
{
    self = [super init];
    if (self) {
        audio    = [OCSParameter         parameterWithString:[self opcodeName]];
        control  = [OCSControl  parameterWithString:[self opcodeName]];
        constant = [OCSConstant parameterWithString:[self opcodeName]];
        output  =  audio;
        min = 0;
        max = 1;
        current = balancePoint;
        in1 = signal1;
        in2 = signal2;
    }
    return self; 
}


- (void)setControl:(OCSControl *)p {
    control = p;
    output = control;
}

- (void)setConstant:(OCSConstant *)p {
    constant = p;
    output = constant;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat: 
            @"%@ ntrpol %@, %@, %@", 
            output, in1, in2, current];
}

/// Gives the CSD string for the output parameter.  
- (NSString *)description {
    return [output parameterString];
}

@end
