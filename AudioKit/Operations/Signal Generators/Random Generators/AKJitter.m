//
//  AKJitter.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's jitter:
//  http://www.csounds.com/manual/html/jitter.html
//

#import "AKJitter.h"
#import "AKManager.h"

@implementation AKJitter

- (instancetype)initWithAmplitude:(AKParameter *)amplitude
                 minimumFrequency:(AKParameter *)minimumFrequency
                 maximumFrequency:(AKParameter *)maximumFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _amplitude = amplitude;
        _minimumFrequency = minimumFrequency;
        _maximumFrequency = maximumFrequency;
        [self setUpConnections];
}
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _amplitude = akp(0.5);
        _minimumFrequency = akp(0);
        _maximumFrequency = akp(60);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)jitter
{
    return [[AKJitter alloc] init];
}

- (void)setAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
    [self setUpConnections];
}

- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    [self setAmplitude:amplitude];
}

- (void)setMinimumFrequency:(AKParameter *)minimumFrequency {
    _minimumFrequency = minimumFrequency;
    [self setUpConnections];
}

- (void)setOptionalMinimumFrequency:(AKParameter *)minimumFrequency {
    [self setMinimumFrequency:minimumFrequency];
}

- (void)setMaximumFrequency:(AKParameter *)maximumFrequency {
    _maximumFrequency = maximumFrequency;
    [self setUpConnections];
}

- (void)setOptionalMaximumFrequency:(AKParameter *)maximumFrequency {
    [self setMaximumFrequency:maximumFrequency];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_amplitude, _minimumFrequency, _maximumFrequency];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"jitter("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ jitter ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    
    if ([_amplitude class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _amplitude];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _amplitude];
    }

    if ([_minimumFrequency class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _minimumFrequency];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _minimumFrequency];
    }

    if ([_maximumFrequency class] == [AKControl class]) {
        [inputsString appendFormat:@"%@", _maximumFrequency];
    } else {
        [inputsString appendFormat:@"AKControl(%@)", _maximumFrequency];
    }
return inputsString;
}

@end
