//
//  AKEqualizerFilter.m
//  AudioKit
//
//  Auto-generated on 2/18/15.
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
        _bandwidth = akp(100);
        _gain = akp(10);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)filterWithInput:(AKParameter *)input
{
    return [[AKEqualizerFilter alloc] initWithInput:input];
}

- (instancetype)initWithPresetDefaultFilterWithInput:(nonnull AKParameter *)input
{
    return [self initWithInput:input];
}

+ (instancetype)presetDefaultFilterWithInput:(nonnull AKParameter *)input
{
    return [[AKEqualizerFilter alloc] initWithInput:input];
}

- (instancetype)initWithPresetNarrowLowFrequencyNotchFilterWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _centerFrequency = akp(500);
        _bandwidth = akp(30);
        _gain = akp(10);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetNarrowLowFrequencyNotchFilterWithInput:(AKParameter *)input;
{
    return [[AKEqualizerFilter alloc] initWithPresetNarrowLowFrequencyNotchFilterWithInput:input];
}

- (instancetype)initWithPresetNarrowHighFrequencyNotchFilterWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _centerFrequency = akp(9000);
        _bandwidth = akp(30);
        _gain = akp(15);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetNarrowHighFrequencyNotchFilterWithInput:(AKParameter *)input;
{
    return [[AKEqualizerFilter alloc] initWithPresetNarrowHighFrequencyNotchFilterWithInput:input];
}


- (instancetype)initWithPresetWideLowFrequencyNotchFilterWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _centerFrequency = akp(500);
        _bandwidth = akp(5000);
        _gain = akp(1);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetWideLowFrequencyNotchFilterWithInput:(AKParameter *)input;
{
    return [[AKEqualizerFilter alloc] initWithPresetWideLowFrequencyNotchFilterWithInput:input];
}

- (instancetype)initWithPresetWideHighFrequencyNotchFilterWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _centerFrequency = akp(9000);
        _bandwidth = akp(5000);
        _gain = akp(15);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetWideHighFrequencyNotchFilterWithInput:(AKParameter *)input;
{
    return [[AKEqualizerFilter alloc] initWithPresetWideHighFrequencyNotchFilterWithInput:input];
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

- (void)setGain:(AKParameter *)gain {
    _gain = gain;
    [self setUpConnections];
}

- (void)setOptionalGain:(AKParameter *)gain {
    [self setGain:gain];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _centerFrequency, _bandwidth, _gain];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"eqfil("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ eqfil ", self];
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
        [inputsString appendFormat:@"%@, ", _bandwidth];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _bandwidth];
    }

    if ([_gain class] == [AKControl class]) {
        [inputsString appendFormat:@"%@", _gain];
    } else {
        [inputsString appendFormat:@"AKControl(%@)", _gain];
    }
return inputsString;
}

@end
