//
//  AKInterpolatedRandomNumberPulse.m
//  AudioKit
//
//  Auto-generated on 12/23/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's randi:
//  http://www.csounds.com/manual/html/randi.html
//

#import "AKInterpolatedRandomNumberPulse.h"
#import "AKManager.h"

@implementation AKInterpolatedRandomNumberPulse

- (instancetype)initWithUpperBound:(AKParameter *)upperBound
                         frequency:(AKParameter *)frequency
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

- (void)setOptionalUpperBound:(AKParameter *)upperBound {
    _upperBound = upperBound;
}
- (void)setOptionalFrequency:(AKParameter *)frequency {
    _frequency = frequency;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ randi AKControl(%@), AKControl(%@)",
            self,
            _upperBound,
            _frequency];
}

@end
