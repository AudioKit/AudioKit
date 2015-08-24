//
//  AKBandRejectButterworthFilter.m
//  AudioKit
//
//  Auto-generated on 2/18/15.
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
        _centerFrequency = akp(3000);
        _bandwidth = akp(2000);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)filterWithInput:(AKParameter *)input
{
    return [[AKBandRejectButterworthFilter alloc] initWithInput:input];
}

- (instancetype)initWithPresetDefaultFilterWithInput:(AKParameter *)input
{
    return [self initWithInput:input];
}

+ (instancetype)presetDefaultFilterWithInput:(AKParameter *)input
{
    return [[AKBandRejectButterworthFilter alloc] initWithInput:input];
}

- (instancetype)initWithPresetBassRejectFilterWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _centerFrequency = akp(100);
        _bandwidth = akp(3000);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetBassRejectFilterWithInput:(AKParameter *)input;
{
    return [[AKBandRejectButterworthFilter alloc] initWithPresetBassRejectFilterWithInput:input];
}

- (instancetype)initWithPresetTrebleRejectFilterWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _centerFrequency = akp(9000);
        _bandwidth = akp(200);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetTrebleRejectFilterWithInput:(AKParameter *)input;
{
    return [[AKBandRejectButterworthFilter alloc] initWithPresetTrebleRejectFilterWithInput:input];
}


- (void)setCenterFrequency:(AKParameter *)centerFrequency {
    _centerFrequency = centerFrequency;
    [self setUpConnections];
}

- (void)setOptionalCenterFrequency:(AKParameter *)centerFrequency {
    [self setCenterFrequency:centerFrequency];
}

- (void)setBandwidth:(AKParameter *)bandwidth {
    _bandwidth = bandwidth;
    [self setUpConnections];
}

- (void)setOptionalBandwidth:(AKParameter *)bandwidth {
    [self setBandwidth:bandwidth];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _centerFrequency, _bandwidth];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"butterbr("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ butterbr ", self];
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

    if ([_centerFrequency class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _centerFrequency];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _centerFrequency];
    }

    if ([_bandwidth class] == [AKControl class]) {
        [inputsString appendFormat:@"%@", _bandwidth];
    } else {
        [inputsString appendFormat:@"AKControl(%@)", _bandwidth];
    }
return inputsString;
}

@end
