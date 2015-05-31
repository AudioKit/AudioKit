//
//  AKFlatFrequencyResponseReverb.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's alpass:
//  http://www.csounds.com/manual/html/alpass.html
//

#import "AKFlatFrequencyResponseReverb.h"
#import "AKManager.h"

@implementation AKFlatFrequencyResponseReverb
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
        _reverbDuration = akp(0.5);
        _loopDuration = akp(0.1);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)reverbWithInput:(AKParameter *)input
{
    return [[AKFlatFrequencyResponseReverb alloc] initWithInput:input];
}

- (instancetype)initWithPresetDefaultReverbWithInput:(AKParameter *)input
{
    return [self initWithInput:input];
}

+ (instancetype)presetDefaultReverbWithInput:(AKParameter *)input
{
    return [[AKFlatFrequencyResponseReverb alloc] initWithInput:input];
}

- (instancetype)initWithPresetMetallicReverbWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Metallic Values
        _reverbDuration = akp(0.8);
        _loopDuration = akp(0.015);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetMetallicReverbWithInput:(AKParameter *)input;
{
    return [[AKFlatFrequencyResponseReverb alloc] initWithPresetMetallicReverbWithInput:input];
}

- (instancetype)initWithPresetStutteringReverbWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Metallic Values
        _reverbDuration = akp(10);
        _loopDuration = akp(0.1);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetStutteringReverbWithInput:(AKParameter *)input;
{
    return [[AKFlatFrequencyResponseReverb alloc] initWithPresetStutteringReverbWithInput:input];
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

    [inlineCSDString appendString:@"alpass("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ alpass ", self];
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
