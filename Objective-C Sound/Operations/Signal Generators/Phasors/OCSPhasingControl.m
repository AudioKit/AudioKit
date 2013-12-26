//
//  OCSPhasingControl.m
//  Objective-C Sound
//
//  Created by Adam Boulanger on 10/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSPhasingControl.h"

@interface OCSPhasingControl () {
    OCSControl *freq;
    OCSConstant *phs;
}

@end

@implementation OCSPhasingControl

- (instancetype)initWithFrequency:(OCSControl *)frequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        freq = frequency;
        phs  = ocsp(0);
    }
    return self;
}

- (void)setOptionalPhase:(OCSConstant *)phase {
    phs = phase;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ phasor %@, %@",
            self, freq, phs];
}

@end
