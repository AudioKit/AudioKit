//
//  AKInterpolatedRandomNumberPulse.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 8/3/14.
//  Modified by Aurelius Prochazka on 8/13/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's randi:
//  http://www.csounds.com/manual/html/randi.html
//

#import "AKInterpolatedRandomNumberPulse.h"

@implementation AKInterpolatedRandomNumberPulse
{
    AKControl *kamp;
    AKControl *kcps;
}

- (instancetype)initWithMaximum:(AKControl *)maximum
                      frequency:(AKControl *)frequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        kamp = maximum;
        kcps = frequency;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ randi %@, %@, 2",
            self, kamp, kcps];  // The ,2 ensures a random seed each time.
}

@end