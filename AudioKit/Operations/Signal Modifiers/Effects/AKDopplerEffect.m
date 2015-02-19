//
//  AKDopplerEffect.m
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's doppler:
//  http://www.csounds.com/manual/html/doppler.html
//

#import "AKDopplerEffect.h"
#import "AKManager.h"

@implementation AKDopplerEffect
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
               sourcePosition:(AKParameter *)sourcePosition
                  micPosition:(AKParameter *)micPosition
    smoothingFilterUpdateRate:(AKConstant *)smoothingFilterUpdateRate
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _sourcePosition = sourcePosition;
        _micPosition = micPosition;
        _smoothingFilterUpdateRate = smoothingFilterUpdateRate;
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
        _sourcePosition = akp(0);
        _micPosition = akp(0);
        _smoothingFilterUpdateRate = akp(6);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)effectWithInput:(AKParameter *)input
{
    return [[AKDopplerEffect alloc] initWithInput:input];
}

- (void)setSourcePosition:(AKParameter *)sourcePosition {
    _sourcePosition = sourcePosition;
    [self setUpConnections];
}

- (void)setOptionalSourcePosition:(AKParameter *)sourcePosition {
    [self setSourcePosition:sourcePosition];
}

- (void)setMicPosition:(AKParameter *)micPosition {
    _micPosition = micPosition;
    [self setUpConnections];
}

- (void)setOptionalMicPosition:(AKParameter *)micPosition {
    [self setMicPosition:micPosition];
}

- (void)setSmoothingFilterUpdateRate:(AKConstant *)smoothingFilterUpdateRate {
    _smoothingFilterUpdateRate = smoothingFilterUpdateRate;
    [self setUpConnections];
}

- (void)setOptionalSmoothingFilterUpdateRate:(AKConstant *)smoothingFilterUpdateRate {
    [self setSmoothingFilterUpdateRate:smoothingFilterUpdateRate];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _sourcePosition, _micPosition, _smoothingFilterUpdateRate];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"doppler("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ doppler ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_soundSpeed = akp(340.29);        
    
    if ([_input class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@, ", _input];
    } else {
        [inputsString appendFormat:@"AKAudio(%@), ", _input];
    }

    if ([_sourcePosition class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _sourcePosition];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _sourcePosition];
    }

    if ([_micPosition class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _micPosition];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _micPosition];
    }

    [inputsString appendFormat:@"%@, ", _soundSpeed];
    
    [inputsString appendFormat:@"%@", _smoothingFilterUpdateRate];
    return inputsString;
}

@end
