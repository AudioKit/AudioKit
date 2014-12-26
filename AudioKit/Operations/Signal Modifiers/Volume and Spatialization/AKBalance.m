//
//  AKBalance.m
//  AudioKit
//
//  Auto-generated on 12/25/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's balance:
//  http://www.csounds.com/manual/html/balance.html
//

#import "AKBalance.h"
#import "AKManager.h"

@implementation AKBalance
{
    AKParameter * _input;
    AKParameter * _comparatorAudioSource;
}

- (instancetype)initWithInput:(AKParameter *)input
        comparatorAudioSource:(AKParameter *)comparatorAudioSource
               halfPowerPoint:(AKConstant *)halfPowerPoint
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _comparatorAudioSource = comparatorAudioSource;
        _halfPowerPoint = halfPowerPoint;
    }
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
        comparatorAudioSource:(AKParameter *)comparatorAudioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _comparatorAudioSource = comparatorAudioSource;
        // Default Values
        _halfPowerPoint = akp(10);
    }
    return self;
}

+ (instancetype)audioWithInput:(AKParameter *)input
        comparatorAudioSource:(AKParameter *)comparatorAudioSource
{
    return [[AKBalance alloc] initWithInput:input
        comparatorAudioSource:comparatorAudioSource];
}

- (void)setOptionalHalfPowerPoint:(AKConstant *)halfPowerPoint {
    _halfPowerPoint = halfPowerPoint;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ balance ", self];

    if ([_input isKindOfClass:[AKAudio class]] ) {
        [csdString appendFormat:@"%@, ", _input];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _input];
    }

    if ([_comparatorAudioSource isKindOfClass:[AKAudio class]] ) {
        [csdString appendFormat:@"%@, ", _comparatorAudioSource];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _comparatorAudioSource];
    }

    [csdString appendFormat:@"%@", _halfPowerPoint];
    return csdString;
}

@end
