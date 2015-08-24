//
//  AKMoogLadder.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's moogladder:
//  http://www.csounds.com/manual/html/moogladder.html
//

#import "AKMoogLadder.h"
#import "AKManager.h"

@implementation AKMoogLadder
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
              cutoffFrequency:(AKParameter *)cutoffFrequency
                    resonance:(AKParameter *)resonance
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
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
        _cutoffFrequency = akp(1000);
        _resonance = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)filterWithInput:(AKParameter *)input
{
    return [[AKMoogLadder alloc] initWithInput:input];
}

- (instancetype)initWithPresetDefaultFilterWithInput:(AKParameter *)input;
{
    return [self initWithInput:input];
}

+ (instancetype)presetDefaultFilterWithInput:(AKParameter *)input;
{
    return [[AKMoogLadder alloc] initWithInput:input];
}

- (instancetype)initWithPresetUnderwaterFilterWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _cutoffFrequency = akp(600);
        _resonance = akp(0.9);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetUnderwaterFilterWithInput:(AKParameter *)input;
{
    return [[AKMoogLadder alloc] initWithPresetUnderwaterFilterWithInput:input];
}

- (instancetype)initWithPresetBassHeavyFilterWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _cutoffFrequency = akp(400);
        _resonance = akp(0.01);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetBassHeavyFilterWithInput:(AKParameter *)input;
{
    return [[AKMoogLadder alloc] initWithPresetBassHeavyFilterWithInput:input];
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
    self.dependencies = @[_input, _cutoffFrequency, _resonance];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"moogladder("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ moogladder ", self];
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
        [inputsString appendFormat:@"%@", _resonance];
    } else {
        [inputsString appendFormat:@"AKControl(%@)", _resonance];
    }
return inputsString;
}

@end
