//
//  AKCompressorExpander.m
//  AudioKit
//
//  Auto-generated on 10/26/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's dam:
//  http://www.csounds.com/manual/html/dam.html
//

#import "AKCompressorExpander.h"
#import "AKManager.h"

@implementation AKCompressorExpander
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
                    threshold:(AKParameter *)threshold
                   lowerRatio:(AKConstant *)lowerRatio
                   upperRatio:(AKConstant *)upperRatio
                   attackTime:(AKConstant *)attackTime
                  releaseTime:(AKConstant *)releaseTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _threshold = threshold;
        _lowerRatio = lowerRatio;
        _upperRatio = upperRatio;
        _attackTime = attackTime;
        _releaseTime = releaseTime;
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
        _threshold = akp(1);
        _lowerRatio = akp(1);
        _upperRatio = akp(1);
        _attackTime = akp(0.05);
        _releaseTime = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)compressorWithInput:(AKParameter *)input
{
    return [[AKCompressorExpander alloc] initWithInput:input];
}

- (void)setThreshold:(AKParameter *)threshold {
    _threshold = threshold;
    [self setUpConnections];
}

- (void)setOptionalThreshold:(AKParameter *)threshold {
    [self setThreshold:threshold];
}

- (void)setLowerRatio:(AKConstant *)lowerRatio {
    _lowerRatio = lowerRatio;
    [self setUpConnections];
}

- (void)setOptionalLowerRatio:(AKConstant *)lowerRatio {
    [self setLowerRatio:lowerRatio];
}

- (void)setUpperRatio:(AKConstant *)upperRatio {
    _upperRatio = upperRatio;
    [self setUpConnections];
}

- (void)setOptionalUpperRatio:(AKConstant *)upperRatio {
    [self setUpperRatio:upperRatio];
}

- (void)setAttackTime:(AKConstant *)attackTime {
    _attackTime = attackTime;
    [self setUpConnections];
}

- (void)setOptionalAttackTime:(AKConstant *)attackTime {
    [self setAttackTime:attackTime];
}

- (void)setReleaseTime:(AKConstant *)releaseTime {
    _releaseTime = releaseTime;
    [self setUpConnections];
}

- (void)setOptionalReleaseTime:(AKConstant *)releaseTime {
    [self setReleaseTime:releaseTime];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _threshold, _lowerRatio, _upperRatio, _attackTime, _releaseTime];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"dam("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ dam ", self];
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

    if ([_threshold class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _threshold];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _threshold];
    }

    [inputsString appendFormat:@"%@, ", _upperRatio];
    
    [inputsString appendFormat:@"%@, ", _lowerRatio];
    
    [inputsString appendFormat:@"%@, ", _attackTime];
    
    [inputsString appendFormat:@"%@", _releaseTime];
    return inputsString;
}

@end
