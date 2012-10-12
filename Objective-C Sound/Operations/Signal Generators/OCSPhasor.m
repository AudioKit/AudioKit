//
//  OCSPhasor.m
//  Sonification
//
//  Created by Adam Boulanger on 10/11/12.
//  Copyright (c) 2012 Adam Boulanger. All rights reserved.
//

#import "OCSPhasor.h"

@interface OCSPhasor ()
{
    OCSParameter * freq;
    OCSConstant * phs;
    
    OCSParameter * output;
}

@end

@implementation OCSPhasor

- (id)initWithFrequency:(OCSParameter *)frequency
{
    self = [super init];
    if (self) {
        output = [OCSParameter parameterWithString:[self operationName]];
        freq = frequency;
        phs  = ocsp(0);
    }
    return self;
}

- (void)setPhase:(OCSConstant *)phase
{
    phs = phase;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ phasor %@, %@",
            output, freq, phs];
}

- (NSString *)description {
    return [output parameterString];
}

@end
