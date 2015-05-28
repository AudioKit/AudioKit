//
//  AKHighPassButterworthFilter.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's butterhp:
//  http://www.csounds.com/manual/html/butterhp.html
//

#import "AKHighPassButterworthFilter.h"
#import "AKManager.h"

@implementation AKHighPassButterworthFilter
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
        _cutoffFrequency = akp(500);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)filterWithInput:(AKParameter *)input
{
    return [[AKHighPassButterworthFilter alloc] initWithInput:input];
}

- (instancetype)initWithPresetDefaultFilterWithInput:(AKParameter *)input;
{
    return [self initWithInput:input];
}

+ (instancetype)presetDefaultFilterWithInput:(AKParameter *)input;
{
    return [[AKHighPassButterworthFilter alloc] initWithInput:input];
}

- (instancetype)initWithPresetModerateFilterWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _cutoffFrequency = akp(2500);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetModerateFilterWithInput:(AKParameter *)input;
{
    return [[AKHighPassButterworthFilter alloc] initWithPresetModerateFilterWithInput:input];
}

- (instancetype)initWithPresetExtremeFilterWithInput:(AKParameter *)input;
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

+ (instancetype)presetExtremeFilterWithInput:(AKParameter *)input;
{
    return [[AKHighPassButterworthFilter alloc] initWithPresetExtremeFilterWithInput:input];
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

    [inlineCSDString appendString:@"butterhp("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ butterhp ", self];
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
