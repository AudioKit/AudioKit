//
//  AKEqualizerFilter.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's eqfil:
//  http://www.csounds.com/manual/html/eqfil.html
//

#import "AKEqualizerFilter.h"
#import "AKManager.h"

@implementation AKEqualizerFilter
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
              centerFrequency:(AKParameter *)centerFrequency
                    bandwidth:(AKParameter *)bandwidth
                         gain:(AKParameter *)gain
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _centerFrequency = centerFrequency;
        _bandwidth = bandwidth;
        _gain = gain;
    }
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _centerFrequency = akp(1000);
        _bandwidth = akp(100);
        _gain = akp(10);
    }
    return self;
}

+ (instancetype)filterWithInput:(AKParameter *)input
{
    return [[AKEqualizerFilter alloc] initWithInput:input];
}

- (void)setOptionalCenterFrequency:(AKParameter *)centerFrequency {
    _centerFrequency = centerFrequency;
}
- (void)setOptionalBandwidth:(AKParameter *)bandwidth {
    _bandwidth = bandwidth;
}
- (void)setOptionalGain:(AKParameter *)gain {
    _gain = gain;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ eqfil ", self];

    if ([_input class] == [AKAudio class]) {
        [csdString appendFormat:@"%@, ", _input];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _input];
    }

    if ([_centerFrequency class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _centerFrequency];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _centerFrequency];
    }

    if ([_bandwidth class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _bandwidth];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _bandwidth];
    }

    if ([_gain class] == [AKControl class]) {
        [csdString appendFormat:@"%@", _gain];
    } else {
        [csdString appendFormat:@"AKControl(%@)", _gain];
    }
return csdString;
}

@end
