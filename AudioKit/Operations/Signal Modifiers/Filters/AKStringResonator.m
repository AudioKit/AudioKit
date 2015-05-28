//
//  AKStringResonator.m
//  AudioKit
//
//  Auto-generated on 3/6/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's streson:
//  http://www.csounds.com/manual/html/streson.html
//

#import "AKStringResonator.h"
#import "AKManager.h"

@implementation AKStringResonator
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
         fundamentalFrequency:(AKParameter *)fundamentalFrequency
                      fdbgain:(AKConstant *)fdbgain
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _fundamentalFrequency = fundamentalFrequency;
        _fdbgain = fdbgain;
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
        _fundamentalFrequency = akp(100);
        _fdbgain = akp(0.95);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)resonatorWithInput:(AKParameter *)input;
{
    return [[AKStringResonator alloc] initWithInput:input];
}

- (instancetype)initWithPresetDefaultResonatorWithInput:(AKParameter *)input;
{
    return [self initWithInput:input];
}

+ (instancetype)presetDefaultResonatorWithInput:(AKParameter *)input;
{
    return [[AKStringResonator alloc] initWithInput:input];
}

- (instancetype)initWithPresetMachineResonatorWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _fundamentalFrequency = akp(75);
        _fdbgain = akp(0.85);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetMachineResonatorWithInput:(AKParameter *)input;
{
    return [[AKStringResonator alloc] initWithPresetMachineResonatorWithInput:input];
}

- (void)setFundamentalFrequency:(AKParameter *)fundamentalFrequency {
    _fundamentalFrequency = fundamentalFrequency;
    [self setUpConnections];
}

- (void)setOptionalFundamentalFrequency:(AKParameter *)fundamentalFrequency {
    [self setFundamentalFrequency:fundamentalFrequency];
}

- (void)setFdbgain:(AKConstant *)fdbgain {
    _fdbgain = fdbgain;
    [self setUpConnections];
}

- (void)setOptionalFdbgain:(AKConstant *)fdbgain {
    [self setFdbgain:fdbgain];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _fundamentalFrequency, _fdbgain];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"streson("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ streson ", self];
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

    if ([_fundamentalFrequency class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _fundamentalFrequency];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _fundamentalFrequency];
    }

    [inputsString appendFormat:@"%@", _fdbgain];
    return inputsString;
}

@end
