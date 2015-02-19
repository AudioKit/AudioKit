//
//  AKRandomNumbers.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's random:
//  http://www.csounds.com/manual/html/random.html
//

#import "AKRandomNumbers.h"
#import "AKManager.h"

@implementation AKRandomNumbers

- (instancetype)initWithLowerBound:(AKParameter *)lowerBound
                        upperBound:(AKParameter *)upperBound
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _lowerBound = lowerBound;
        _upperBound = upperBound;
        [self setUpConnections];
}
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _lowerBound = akp(0);
        _upperBound = akp(1);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)numbers
{
    return [[AKRandomNumbers alloc] init];
}

- (void)setLowerBound:(AKParameter *)lowerBound {
    _lowerBound = lowerBound;
    [self setUpConnections];
}

- (void)setOptionalLowerBound:(AKParameter *)lowerBound {
    [self setLowerBound:lowerBound];
}

- (void)setUpperBound:(AKParameter *)upperBound {
    _upperBound = upperBound;
    [self setUpConnections];
}

- (void)setOptionalUpperBound:(AKParameter *)upperBound {
    [self setUpperBound:upperBound];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_lowerBound, _upperBound];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"random("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ random ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    
    if ([_lowerBound class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _lowerBound];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _lowerBound];
    }

    if ([_upperBound class] == [AKControl class]) {
        [inputsString appendFormat:@"%@", _upperBound];
    } else {
        [inputsString appendFormat:@"AKControl(%@)", _upperBound];
    }
return inputsString;
}

@end
