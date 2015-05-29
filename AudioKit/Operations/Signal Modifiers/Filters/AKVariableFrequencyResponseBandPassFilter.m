//
//  AKVariableFrequencyResponseBandPassFilter.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Customized by Aurelius Prochazka to add type helpers

//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's resonz:
//  http://www.csounds.com/manual/html/resonz.html
//

#import "AKVariableFrequencyResponseBandPassFilter.h"
#import "AKManager.h"

@implementation AKVariableFrequencyResponseBandPassFilter
{
    AKParameter * _input;
}

+ (AKConstant *)scalingFactorNone { return akp(0); }
+ (AKConstant *)scalingFactorPeak { return akp(1); }
+ (AKConstant *)scalingFactorRMS  { return akp(2); }

- (instancetype)initWithInput:(AKParameter *)input
                    cutoffFrequency:(AKParameter *)cutoffFrequency
                          bandwidth:(AKParameter *)bandwidth
                      scalingFactor:(AKConstant *)scalingFactor
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _cutoffFrequency = cutoffFrequency;
        _bandwidth = bandwidth;
        _scalingFactor = scalingFactor;
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
        _cutoffFrequency = akp(1000);
        _bandwidth = akp(10);
        _scalingFactor = akp(1);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)filterWithInput:(AKParameter *)input
{
    return [[AKVariableFrequencyResponseBandPassFilter alloc] initWithInput:input];
}

- (instancetype)initWithPresetMuffledFilterWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _cutoffFrequency = akp(500);
        _bandwidth = akp(10);
        _scalingFactor = akp(1);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetMuffledFilterWithInput:(AKParameter *)input;
{
    return [[AKVariableFrequencyResponseBandPassFilter alloc] initWithPresetMuffledFilterWithInput:input];
}

- (instancetype)initWithPresetLargeMuffledFilterWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _cutoffFrequency = akp(500);
        _bandwidth = akp(5);
        _scalingFactor = akp(2);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetLargeMuffledFilterWithInput:(AKParameter *)input;
{
    return [[AKVariableFrequencyResponseBandPassFilter alloc] initWithPresetLargeMuffledFilterWithInput:input];
}

- (instancetype)initWithPresetTreblePeakFilterWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _cutoffFrequency = akp(3000);
        _bandwidth = akp(5);
        _scalingFactor = akp(2);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetTreblePeakFilterWithInput:(AKParameter *)input;
{
    return [[AKVariableFrequencyResponseBandPassFilter alloc] initWithPresetTreblePeakFilterWithInput:input];
}

- (instancetype)initWithPresetBassPeakFilterWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _cutoffFrequency = akp(200);
        _bandwidth = akp(1);
        _scalingFactor = akp(2);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetBassPeakFilterWithInput:(AKParameter *)input;
{
    return [[AKVariableFrequencyResponseBandPassFilter alloc] initWithPresetBassPeakFilterWithInput:input];
}



- (instancetype)initWithPresetDefaultFilterWithInput:(AKParameter *)input;
{
    return [self initWithInput:input];
}

+ (instancetype)presetDefautFilterWithInput:(AKParameter *)input;
{
    return [[AKVariableFrequencyResponseBandPassFilter alloc] initWithInput:input];
}

- (void)setCutoffFrequency:(AKParameter *)cutoffFrequency {
    _cutoffFrequency = cutoffFrequency;
    [self setUpConnections];
}

- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency {
    [self setCutoffFrequency:cutoffFrequency];
}

- (void)setBandwidth:(AKParameter *)bandwidth {
    _bandwidth = bandwidth;
    [self setUpConnections];
}

- (void)setOptionalBandwidth:(AKParameter *)bandwidth {
    [self setBandwidth:bandwidth];
}

- (void)setScalingFactor:(AKConstant *)scalingFactor {
    _scalingFactor = scalingFactor;
    [self setUpConnections];
}

- (void)setOptionalScalingFactor:(AKConstant *)scalingFactor {
    [self setScalingFactor:scalingFactor];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _cutoffFrequency, _bandwidth, _scalingFactor];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"resonz("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ resonz ", self];
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

    if ([_cutoffFrequency class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _cutoffFrequency];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _cutoffFrequency];
    }

    if ([_bandwidth class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _bandwidth];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _bandwidth];
    }

    [inputsString appendFormat:@"%@", _scalingFactor];
    return inputsString;
}

@end
