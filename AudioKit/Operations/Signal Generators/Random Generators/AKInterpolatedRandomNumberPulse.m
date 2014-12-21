//
//  AKInterpolatedRandomNumberPulse.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's randi:
//  http://www.csounds.com/manual/html/randi.html
//

#import "AKInterpolatedRandomNumberPulse.h"
#import "AKManager.h"

@implementation AKInterpolatedRandomNumberPulse

- (instancetype)initWithUpperBound:(AKControl *)upperBound
                         frequency:(AKControl *)frequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _upperBound = upperBound;
        _frequency = frequency;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _upperBound = akp(1);    
        _frequency = akp(1);    
    }
    return self;
}

+ (instancetype)control
{
    return [[AKInterpolatedRandomNumberPulse alloc] init];
}

- (void)setOptionalUpperBound:(AKControl *)upperBound {
    _upperBound = upperBound;
}
- (void)setOptionalFrequency:(AKControl *)frequency {
    _frequency = frequency;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ randi %@, %@",
            self,
            _upperBound,
            _frequency];
}

@end
