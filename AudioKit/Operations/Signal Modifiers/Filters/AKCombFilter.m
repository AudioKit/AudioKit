//
//  AKCombFilter.m
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's comb:
//  http://www.csounds.com/manual/html/comb.html
//

#import "AKCombFilter.h"
#import "AKManager.h"

@implementation AKCombFilter
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
               reverbDuration:(AKParameter *)reverbDuration
                 loopDuration:(AKConstant *)loopDuration
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _reverbDuration = reverbDuration;
        _loopDuration = loopDuration;
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
        _reverbDuration = akp(1);
        _loopDuration = akp(0.1);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)filterWithInput:(AKParameter *)input
{
    return [[AKCombFilter alloc] initWithInput:input];
}

- (instancetype)initWithPresetDefaultFilterWithInput:(AKParameter *)input;
{
    return [self initWithInput:input];
}

+ (instancetype)presetDefaultFilterWithInput:(AKParameter *)input;
{
    return [[AKCombFilter alloc] initWithInput:input];
}

- (instancetype)initWithPresetSpringyFilterWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _reverbDuration = akp(0.75);
        _loopDuration = akp(0.01);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetSpringFilterWithInput:(AKParameter *)input;
{
    return [[AKCombFilter alloc] initWithPresetSpringyFilterWithInput:input];
}

- (instancetype)initWithPresetShuffleFilterWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _reverbDuration = akp(2);
        _loopDuration = akp(0.2);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetShuffleFilterWithInput:(AKParameter *)input;
{
    return [[AKCombFilter alloc] initWithPresetShuffleFilterWithInput:input];
}

- (void)setReverbDuration:(AKParameter *)reverbDuration {
    _reverbDuration = reverbDuration;
    [self setUpConnections];
}

- (void)setOptionalReverbDuration:(AKParameter *)reverbDuration {
    [self setReverbDuration:reverbDuration];
}

- (void)setLoopDuration:(AKConstant *)loopDuration {
    _loopDuration = loopDuration;
    [self setUpConnections];
}

- (void)setOptionalLoopDuration:(AKConstant *)loopDuration {
    [self setLoopDuration:loopDuration];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _reverbDuration, _loopDuration];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"comb("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ comb ", self];
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

    if ([_reverbDuration class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _reverbDuration];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _reverbDuration];
    }

    [inputsString appendFormat:@"%@", _loopDuration];
    return inputsString;
}

@end
