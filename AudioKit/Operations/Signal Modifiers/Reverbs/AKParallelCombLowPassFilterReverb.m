//
//  AKParallelCombLowPassFilterReverb.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's nreverb:
//  http://www.csounds.com/manual/html/nreverb.html
//

#import "AKParallelCombLowPassFilterReverb.h"
#import "AKManager.h"

@implementation AKParallelCombLowPassFilterReverb
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
                     duration:(AKParameter *)duration
     highFrequencyDiffusivity:(AKParameter *)highFrequencyDiffusivity
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _duration = duration;
        _highFrequencyDiffusivity = highFrequencyDiffusivity;
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
        _duration = akp(0.1);
        _highFrequencyDiffusivity = akp(0.2);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)reverbWithInput:(AKParameter *)input
{
    return [[AKParallelCombLowPassFilterReverb alloc] initWithInput:input];
}

- (void)setDuration:(AKParameter *)duration {
    _duration = duration;
    [self setUpConnections];
}

- (void)setOptionalDuration:(AKParameter *)duration {
    [self setDuration:duration];
}

- (void)setHighFrequencyDiffusivity:(AKParameter *)highFrequencyDiffusivity {
    _highFrequencyDiffusivity = highFrequencyDiffusivity;
    [self setUpConnections];
}

- (void)setOptionalHighFrequencyDiffusivity:(AKParameter *)highFrequencyDiffusivity {
    [self setHighFrequencyDiffusivity:highFrequencyDiffusivity];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _duration, _highFrequencyDiffusivity];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"nreverb("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ nreverb ", self];
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

    if ([_duration class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _duration];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _duration];
    }

    if ([_highFrequencyDiffusivity class] == [AKControl class]) {
        [inputsString appendFormat:@"%@", _highFrequencyDiffusivity];
    } else {
        [inputsString appendFormat:@"AKControl(%@)", _highFrequencyDiffusivity];
    }
return inputsString;
}

@end
