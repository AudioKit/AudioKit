//
//  AKMixedControl.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/12/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKMixedControl.h"

@implementation AKMixedControl
{
    AKControl *in1;
    AKControl *in2;
    AKConstant *min;
    AKConstant *max;
    AKParameter *current;
}

- (instancetype)initWithControl1:(AKControl *)control1
                        control2:(AKControl *)control2
                         balance:(AKControl *)balancePoint;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        min = akp(0.0);
        max = akp(1.0);
        current = balancePoint;
        in1 = control1;
        in2 = control2;
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
            @"%@ ntrpol %@, %@, %@, %@, %@",
            self, in1, in2, current, min, max];
}

@end
