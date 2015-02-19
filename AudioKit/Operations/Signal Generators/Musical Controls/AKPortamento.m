//
//  AKPortamento.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's portk:
//  http://www.csounds.com/manual/html/portk.html
//

#import "AKPortamento.h"
#import "AKManager.h"

@implementation AKPortamento
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
                     halfTime:(AKParameter *)halfTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _halfTime = halfTime;
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
        _halfTime = akp(1);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)portamentoWithInput:(AKParameter *)input
{
    return [[AKPortamento alloc] initWithInput:input];
}

- (void)setHalfTime:(AKParameter *)halfTime {
    _halfTime = halfTime;
    [self setUpConnections];
}

- (void)setOptionalHalfTime:(AKParameter *)halfTime {
    [self setHalfTime:halfTime];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _halfTime];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"portk("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ portk ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    
    if ([_input class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _input];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _input];
    }

    if ([_halfTime class] == [AKControl class]) {
        [inputsString appendFormat:@"%@", _halfTime];
    } else {
        [inputsString appendFormat:@"AKControl(%@)", _halfTime];
    }
return inputsString;
}

@end
