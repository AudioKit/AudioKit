//
//  AKJitter.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's jitter:
//  http://www.csounds.com/manual/html/jitter.html
//

#import "AKJitter.h"
#import "AKManager.h"

@implementation AKJitter

- (instancetype)initWithAmplitude:(AKParameter *)amplitude
                 minimumFrequency:(AKParameter *)minimumFrequency
                 maximumFrequency:(AKParameter *)maximumFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _amplitude = amplitude;
        _minimumFrequency = minimumFrequency;
        _maximumFrequency = maximumFrequency;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _amplitude = akp(1);
        _minimumFrequency = akp(0);
        _maximumFrequency = akp(60);
    }
    return self;
}

+ (instancetype)jitter
{
    return [[AKJitter alloc] init];
}

- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
}
- (void)setOptionalMinimumFrequency:(AKParameter *)minimumFrequency {
    _minimumFrequency = minimumFrequency;
}
- (void)setOptionalMaximumFrequency:(AKParameter *)maximumFrequency {
    _maximumFrequency = maximumFrequency;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ jitter ", self];

    if ([_amplitude class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _amplitude];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _amplitude];
    }

    if ([_minimumFrequency class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _minimumFrequency];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _minimumFrequency];
    }

    if ([_maximumFrequency class] == [AKControl class]) {
        [csdString appendFormat:@"%@", _maximumFrequency];
    } else {
        [csdString appendFormat:@"AKControl(%@)", _maximumFrequency];
    }
return csdString;
}

@end
