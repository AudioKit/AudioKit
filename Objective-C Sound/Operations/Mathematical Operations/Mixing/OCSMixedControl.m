//
//  OCSMixedControl.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSMixedControl.h"


@interface OCSMixedControl () {
    OCSControl *in1;
    OCSControl *in2;
    OCSConstant *min;
    OCSConstant *max;
    OCSParameter *current;
}
@end

@implementation OCSMixedControl

- (instancetype)initWithControl1:(OCSControl *)control1
                        control2:(OCSControl *)control2
                         balance:(OCSControl *)balancePoint;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        min = ocsp(0.0);
        max = ocsp(1.0);
        current = balancePoint;
        in1 = control1;
        in2 = control2;
    }
    return self;
}

- (void)setMinimumBalancePoint:(OCSConstant *)minimumBalancePoint {
    min = minimumBalancePoint;
}
- (void)setMaximumBalancePoint:(OCSConstant *)maximumBalancePoint {
    max = maximumBalancePoint;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ ntrpol %@, %@, %@, %@, %@",
            self, in1, in2, current, min, max];
}

@end
