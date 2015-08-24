//
//  AKLowPassFilter.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's tone:
//  http://www.csounds.com/manual/html/tone.html
//

#import "AKLowPassFilter.h"
#import "AKManager.h"

@implementation AKLowPassFilter
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
                     halfPowerPoint:(AKParameter *)halfPowerPoint
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _halfPowerPoint = halfPowerPoint;
        [self setUpConnections];
}
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _halfPowerPoint = akp(1000);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)filterWithInput:(AKParameter *)input
{
    return [[AKLowPassFilter alloc] initWithInput:input];
}

- (instancetype)initWithPresetDefaultFilterWithInput:(AKParameter *)input;
{
    return [self initWithInput:input];
}

+ (instancetype)presetDefaultFilterWithInput:(AKParameter *)input;
{
    return [[AKLowPassFilter alloc] initWithInput:input];
}

- (instancetype)initWithPresetMuffledFilterWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _halfPowerPoint = akp(100);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetMuffledFilterWithInput:(AKParameter *)input;
{
    return [[AKLowPassFilter alloc] initWithPresetMuffledFilterWithInput:input];
}

- (void)setHalfPowerPoint:(AKParameter *)halfPowerPoint {
    _halfPowerPoint = halfPowerPoint;
    [self setUpConnections];
}

- (void)setOptionalHalfPowerPoint:(AKParameter *)halfPowerPoint {
    [self setHalfPowerPoint:halfPowerPoint];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _halfPowerPoint];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"tone("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ tone ", self];
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

    if ([_halfPowerPoint class] == [AKControl class]) {
        [inputsString appendFormat:@"%@", _halfPowerPoint];
    } else {
        [inputsString appendFormat:@"AKControl(%@)", _halfPowerPoint];
    }
return inputsString;
}

@end
