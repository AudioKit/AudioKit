//
//  AKInterpolatedRandomNumberPulse.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's randi:
//  http://www.csounds.com/manual/html/randi.html
//

#import "AKInterpolatedRandomNumberPulse.h"
#import "AKManager.h"

@implementation AKInterpolatedRandomNumberPulse

- (instancetype)initWithUpperBound:(AKParameter *)upperBound
                         frequency:(AKParameter *)frequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _upperBound = upperBound;
        _frequency = frequency;
        [self setUpConnections];
}
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _upperBound = akp(1);
        _frequency = akp(1);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)pulse
{
    return [[AKInterpolatedRandomNumberPulse alloc] init];
}

- (void)setUpperBound:(AKParameter *)upperBound {
    _upperBound = upperBound;
    [self setUpConnections];
}

- (void)setOptionalUpperBound:(AKParameter *)upperBound {
    [self setUpperBound:upperBound];
}

- (void)setFrequency:(AKParameter *)frequency {
    _frequency = frequency;
    [self setUpConnections];
}

- (void)setOptionalFrequency:(AKParameter *)frequency {
    [self setFrequency:frequency];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_upperBound, _frequency];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"randi:a("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ randi ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    
    [inputsString appendFormat:@"%@, ", _upperBound];
    
    [inputsString appendFormat:@"%@", _frequency];
    return inputsString;
}

@end
