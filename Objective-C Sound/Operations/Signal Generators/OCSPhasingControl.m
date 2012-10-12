//
//  OCSPhasingControl.m
//  Sonification
//
//  Created by Adam Boulanger on 10/11/12.
//  Copyright (c) 2012 Adam Boulanger. All rights reserved.
//

#import "OCSPhasingControl.h"

@interface OCSPhasingControl ()
{
    OCSControl * freq;
    OCSConstant * phs;
    
    OCSParameter * output;
}

@end

@implementation OCSPhasingControl

- (id)initWithFrequency:(OCSControl *)frequency
{
    self = [super init];
    if (self) {
        output = [OCSControl parameterWithString:[self operationName]];
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
