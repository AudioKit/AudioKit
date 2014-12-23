//
//  AKMixedAudio.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/28/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's ntrpol:
//  http://www.csounds.com/manual/html/ntrpol.html
//

#import "AKMixedAudio.h"

@implementation AKMixedAudio
{
    AKAudio *in1;
    AKAudio *in2;
    AKConstant *min;
    AKConstant *max;
    AKControl *current;
}

- (instancetype)initWithSignal1:(AKAudio *)signal1
                        signal2:(AKAudio *)signal2
                        balance:(AKControl *)balancePoint;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        min = akp(0.0);
        max = akp(1.0);
        current = balancePoint;
        in1 = signal1;
        in2 = signal2;
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
