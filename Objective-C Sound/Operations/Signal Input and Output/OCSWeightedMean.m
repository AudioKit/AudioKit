//
//  OCSWeightedMean.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's ntrpol:
//  http://www.csounds.com/manual/html/ntrpol.html
//

#import "OCSWeightedMean.h"

@interface OCSWeightedMean () {
    OCSParameter *in1;
    OCSParameter *in2;
    OCSConstant *min;
    OCSConstant *max;
    OCSParameter *current;

    OCSParameter *audio;
    OCSControl *control;
    OCSConstant *constant;
    OCSParameter *output;
}
@end

@implementation OCSWeightedMean

@synthesize control;
@synthesize constant;
@synthesize output;

- (id)initWithSignal1:(OCSParameter *)signal1 
              signal2:(OCSParameter *)signal2
              balance:(OCSParameter *)balancePoint;
{
    return [self initWithSignal1:signal1 
                         signal2:signal2 
                         balance:balancePoint
                         minimum:ocsp(0.0) 
                         maximum:ocsp(1.0)];
}

- (id)initWithSignal1:(OCSParameter *)signal1 
              signal2:(OCSParameter *)signal2
              balance:(OCSParameter *)balancePoint
              minimum:(OCSConstant *)minimum
              maximum:(OCSConstant *)maximum;
{
    self = [super init];
    if (self) {
        audio    = [OCSParameter parameterWithString:[self operationName]];
        control  = [OCSControl   parameterWithString:[self operationName]];
        constant = [OCSConstant  parameterWithString:[self operationName]];
        output  =  audio;
        min = minimum;
        max = maximum;
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
            @"%@ ntrpol %@, %@, %@, %@, %@", 
            output, in1, in2, current, min, max];
}

- (NSString *)description {
    return [output parameterString];
}

@end
