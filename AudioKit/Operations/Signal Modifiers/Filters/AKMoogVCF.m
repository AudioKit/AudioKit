//
//  AKMoogVCF.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's moogvcf2:
//  http://www.csounds.com/manual/html/moogvcf2.html
//

#import "AKMoogVCF.h"
#import "AKManager.h"

@implementation AKMoogVCF
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
    return [[AKMoogVCF alloc] initWithInput:input];
}

- (instancetype)initWithPresetDefaultFilterWithInput:(AKParameter *)input;
{
    return [self initWithInput:input];
}

+ (instancetype)presetDefaultFilterWithInput:(AKParameter *)input;
{
    return [[AKMoogVCF alloc] initWithInput:input];
}

- (instancetype)initWithPresetHighTrebleFilterWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _cutoffFrequency = akp(2000);
        _resonance = akp(0.9);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetHighTrebleFilterWithInput:(AKParameter *)input;
{
    return [[AKMoogVCF alloc] initWithPresetHighTrebleFilterWithInput:input];
}

- (instancetype)initWithPresetFoggyBottomFilterWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _cutoffFrequency = akp(500);
        _resonance = akp(0.99);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetFoggyBottomFilterWithInput:(AKParameter *)input;
{
    return [[AKMoogVCF alloc] initWithPresetFoggyBottomFilterWithInput:input];
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

    [inlineCSDString appendString:@"moogvcf2("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ moogvcf2 ", self];
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

    [inputsString appendFormat:@"%@, ", _cutoffFrequency];
    
    [inputsString appendFormat:@"%@", _resonance];
    return inputsString;
}

@end
