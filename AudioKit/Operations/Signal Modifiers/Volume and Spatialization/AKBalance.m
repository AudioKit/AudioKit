//
//  AKBalance.m
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
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
        [self setUpConnections];
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
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)balanceWithInput:(AKParameter *)input
          comparatorAudioSource:(AKParameter *)comparatorAudioSource
{
    return [[AKBalance alloc] initWithInput:input
          comparatorAudioSource:comparatorAudioSource];
}

- (void)setHalfPowerPoint:(AKConstant *)halfPowerPoint {
    _halfPowerPoint = halfPowerPoint;
    [self setUpConnections];
}

- (void)setOptionalHalfPowerPoint:(AKConstant *)halfPowerPoint {
    [self setHalfPowerPoint:halfPowerPoint];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _comparatorAudioSource, _halfPowerPoint];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"balance("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ balance ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    
    if ([_input class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@, ", _input];
    } else {
        [inputsString appendFormat:@"AKAudio(%@), ", _input];
    }

    if ([_comparatorAudioSource class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@, ", _comparatorAudioSource];
    } else {
        [inputsString appendFormat:@"AKAudio(%@), ", _comparatorAudioSource];
    }

    [inputsString appendFormat:@"%@", _halfPowerPoint];
    return inputsString;
}

@end
