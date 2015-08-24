//
//  AKHighPassFilter.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's atone:
//  http://www.csounds.com/manual/html/atone.html
//

#import "AKHighPassFilter.h"
#import "AKManager.h"

@implementation AKHighPassFilter
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
              cutoffFrequency:(AKParameter *)cutoffFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _cutoffFrequency = cutoffFrequency;
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
        _cutoffFrequency = akp(4000);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)filterWithInput:(AKParameter *)input
{
    return [[AKHighPassFilter alloc] initWithInput:input];
}

- (instancetype)initWithPresetDefaultFilterWithInput:(AKParameter *)input;
{
    return [self initWithInput:input];
}

+ (instancetype)presetDefaultFilterWithInput:(AKParameter *)input;
{
    return [[AKHighPassFilter alloc] initWithInput:input];
}

- (instancetype)initWithPresetHighCutoffFilterWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _cutoffFrequency = akp(10000);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetHighCutoffFilterWithInput:(AKParameter *)input;
{
    return [[AKHighPassFilter alloc] initWithPresetHighCutoffFilterWithInput:input];
}

- (void)setCutoffFrequency:(AKParameter *)cutoffFrequency {
    _cutoffFrequency = cutoffFrequency;
    [self setUpConnections];
}

- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency {
    [self setCutoffFrequency:cutoffFrequency];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _cutoffFrequency];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"atone("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ atone ", self];
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
        [inputsString appendFormat:@"%@", _cutoffFrequency];
    } else {
        [inputsString appendFormat:@"AKControl(%@)", _cutoffFrequency];
    }
return inputsString;
}

@end
