//
//  AKThreePoleLowpassFilter.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's lpf18:
//  http://www.csounds.com/manual/html/lpf18.html
//

#import "AKThreePoleLowpassFilter.h"
#import "AKManager.h"

@implementation AKThreePoleLowpassFilter
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
                   distortion:(AKParameter *)distortion
              cutoffFrequency:(AKParameter *)cutoffFrequency
                    resonance:(AKParameter *)resonance
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _distortion = distortion;
        _cutoffFrequency = cutoffFrequency;
        _resonance = resonance;
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
        _distortion = akp(0.5);
        _cutoffFrequency = akp(1500);
        _resonance = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)filterWithInput:(AKParameter *)input
{
    return [[AKThreePoleLowpassFilter alloc] initWithInput:input];
}

- (instancetype)initWithPresetDefaultFilterWithInput:(AKParameter *)input;
{
    return [self initWithInput:input];
}

+ (instancetype)presetDefaultFilterWithInput:(AKParameter *)input;
{
    return [[AKThreePoleLowpassFilter alloc] initWithInput:input];
}

- (instancetype)initWithPresetBrightFilterWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _distortion = akp(1);
        _cutoffFrequency = akp(9000);
        _resonance = akp(1);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetBrightFilterWithInput:(AKParameter *)input;
{
    return [[AKThreePoleLowpassFilter alloc] initWithPresetBrightFilterWithInput:input];
}

- (instancetype)initWithPresetDullBassWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _distortion = akp(0.9);
        _cutoffFrequency = akp(150);
        _resonance = akp(0.9);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetDullBassWithInput:(AKParameter *)input;
{
    return [[AKThreePoleLowpassFilter alloc] initWithPresetDullBassWithInput:input];
}

- (instancetype)initWithPresetScreamWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _distortion = akp(0.9);
        _cutoffFrequency = akp(1000);
        _resonance = akp(1);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetScreamWithInput:(AKParameter *)input;
{
    return [[AKThreePoleLowpassFilter alloc] initWithPresetScreamWithInput:input];
}

- (void)setDistortion:(AKParameter *)distortion {
    _distortion = distortion;
    [self setUpConnections];
}

- (void)setOptionalDistortion:(AKParameter *)distortion {
    [self setDistortion:distortion];
}

- (void)setCutoffFrequency:(AKParameter *)cutoffFrequency {
    _cutoffFrequency = cutoffFrequency;
    [self setUpConnections];
}

- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency {
    [self setCutoffFrequency:cutoffFrequency];
}

- (void)setResonance:(AKParameter *)resonance {
    _resonance = resonance;
    [self setUpConnections];
}

- (void)setOptionalResonance:(AKParameter *)resonance {
    [self setResonance:resonance];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _distortion, _cutoffFrequency, _resonance];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"lpf18("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ lpf18 ", self];
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

    if ([_resonance class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _resonance];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _resonance];
    }

    if ([_distortion class] == [AKControl class]) {
        [inputsString appendFormat:@"%@", _distortion];
    } else {
        [inputsString appendFormat:@"AKControl(%@)", _distortion];
    }
return inputsString;
}

@end
