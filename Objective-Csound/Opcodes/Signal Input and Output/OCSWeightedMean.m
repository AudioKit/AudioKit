//
//  OCSWeightedMean.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSWeightedMean.h"

@interface OCSWeightedMean () {
    OCSParam *in1;
    OCSParam *in2;
    float min;
    float max;
    OCSParam *current;

    OCSParam *audio;
    OCSControlParam *control;
    OCSConstantParam *constant;
    OCSParam *output;
}
@end

@implementation OCSWeightedMean


@synthesize audio;
@synthesize control;
@synthesize constant;
@synthesize output;

- (id)initWithSignal1:(OCSParam *)signal1 
              signal2:(OCSParam *)signal2
              balance:(OCSParam *)balancePoint;
{
    self = [super init];
    if (self) {
        audio    = [OCSParam         paramWithString:[self opcodeName]];
        control  = [OCSControlParam  paramWithString:[self opcodeName]];
        constant = [OCSConstantParam paramWithString:[self opcodeName]];
        output  =  audio;
        min = 0;
        max = 1;
        current = balancePoint;
        in1 = signal1;
        in2 = signal2;
    }
    return self; 
}


- (void)setControl:(OCSControlParam *)p {
    control = p;
    output = control;
}

- (void)setConstant:(OCSConstantParam *)p {
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
