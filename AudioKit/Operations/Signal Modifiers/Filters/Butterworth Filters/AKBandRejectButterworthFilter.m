//
//  AKBandRejectButterworthFilter.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's butterbr:
//  http://www.csounds.com/manual/html/butterbr.html
//

#import "AKBandRejectButterworthFilter.h"
#import "AKManager.h"

@implementation AKBandRejectButterworthFilter
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
              centerFrequency:(AKParameter *)centerFrequency
                    bandwidth:(AKParameter *)bandwidth
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _centerFrequency = centerFrequency;
        _bandwidth = bandwidth;
    }
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _centerFrequency = akp(3000);
        _bandwidth = akp(2000);
    }
    return self;
}

+ (instancetype)filterWithInput:(AKParameter *)input
{
    return [[AKBandRejectButterworthFilter alloc] initWithInput:input];
}

- (void)setOptionalCenterFrequency:(AKParameter *)centerFrequency {
    _centerFrequency = centerFrequency;
}
- (void)setOptionalBandwidth:(AKParameter *)bandwidth {
    _bandwidth = bandwidth;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ butterbr ", self];

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
        [csdString appendFormat:@"%@", _bandwidth];
    } else {
        [csdString appendFormat:@"AKControl(%@)", _bandwidth];
    }
return csdString;
}

@end
