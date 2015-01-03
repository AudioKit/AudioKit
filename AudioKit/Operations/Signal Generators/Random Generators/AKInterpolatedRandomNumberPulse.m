//
//  AKInterpolatedRandomNumberPulse.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
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

+ (instancetype)pulse
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
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ randi ", self];

    if ([_upperBound class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _upperBound];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _upperBound];
    }

    if ([_frequency class] == [AKControl class]) {
        [csdString appendFormat:@"%@", _frequency];
    } else {
        [csdString appendFormat:@"AKControl(%@)", _frequency];
    }
return csdString;
}

@end
