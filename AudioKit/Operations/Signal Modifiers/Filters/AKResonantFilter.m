//
//  AKResonantFilter.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Customized by Aurelius Prochazka on 5/30/15 to include tival() and peak scaling.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's reson:
//  http://www.csounds.com/manual/html/reson.html
//

#import "AKResonantFilter.h"
#import "AKManager.h"

@implementation AKResonantFilter
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
        _centerFrequency = akp(1000);
        _bandwidth = akp(10);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)filterWithInput:(AKParameter *)input
{
    return [[AKResonantFilter alloc] initWithInput:input];
}

- (instancetype)initWithPresetDefaultFilterWithInput:(AKParameter *)input;
{
    return [self initWithInput:input];
}

+ (instancetype)presetDefaultFilterWithInput:(AKParameter *)input;
{
    return [[AKResonantFilter alloc] initWithInput:input];
}

- (instancetype)initWithPresetMuffledFilterWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _centerFrequency = akp(100);
        _bandwidth = akp(500);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetMuffledFilterWithInput:(AKParameter *)input;
{
    return [[AKResonantFilter alloc] initWithPresetMuffledFilterWithInput:input];
}

- (instancetype)initWithPresetHighTrebleFilterWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _centerFrequency = akp(7000);
        _bandwidth = akp(900);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetHighTrebleFilterWithInput:(AKParameter *)input;
{
    return [[AKResonantFilter alloc] initWithPresetHighTrebleFilterWithInput:input];
}

- (instancetype)initWithPresetHighBassFilterWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _centerFrequency = akp(350);
        _bandwidth = akp(50);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetHighBassFilterWithInput:(AKParameter *)input;
{
    return [[AKResonantFilter alloc] initWithPresetHighBassFilterWithInput:input];
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
    
    [inlineCSDString appendString:@"reson("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];
    
    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    [csdString appendFormat:@"%@ reson ", self];
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
    [inputsString appendString:@", 1, tival()"];
    return inputsString;
}

@end
