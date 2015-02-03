//
//  AKMix.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/28/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's ntrpol:
//  http://www.csounds.com/manual/html/ntrpol.html
//

#import "AKMix.h"

@implementation AKMix
{
    AKParameter *in1;
    AKParameter *in2;
    AKConstant *min;
    AKConstant *max;
    AKParameter *current;
}

- (instancetype)initWithInput1:(AKParameter *)input1
                        input2:(AKParameter *)input2
                        balance:(AKParameter *)balancePoint;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        min = akp(0.0);
        max = akp(1.0);
        current = balancePoint;
        in1 = input1;
        in2 = input2;
    }
    return self;
}


- (void)setMinimumBalancePoint:(AKConstant *)minimumBalancePoint {
    min = minimumBalancePoint;
}
- (void)setMaximumBalancePoint:(AKConstant *)maximumBalancePoint {
    max = maximumBalancePoint;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ ntrpol AKAudio(%@), AKAudio(%@), AKControl(%@), %@, %@",
            self, in1, in2, current, min, max];
}

@end
