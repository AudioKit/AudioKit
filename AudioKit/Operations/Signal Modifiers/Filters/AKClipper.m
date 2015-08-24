//
//  AKClipper.m
//  AudioKit
//
//  Auto-generated on 7/10/15. (Motivated by Daniel Clelland)
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's clip:
//  http://www.csounds.com/manual/html/clip.html
//

#import "AKClipper.h"
#import "AKManager.h"

@implementation AKClipper
{
    AKParameter * _input;
}

+ (AKConstant *)clippingMethodBramDeJong { return akp(0); }
+ (AKConstant *)clippingMethodSine       { return akp(1); }
+ (AKConstant *)clippingMethodTanh       { return akp(2); }

- (instancetype)initWithInput:(AKParameter *)input
                        limit:(AKConstant *)limit
                       method:(AKConstant *)method
           clippingStartPoint:(AKConstant *)clippingStartPoint
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _limit = limit;
        _method = method;
        _clippingStartPoint = clippingStartPoint;
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
        _limit = akp(1);
        _method = [AKClipper clippingMethodBramDeJong];
        _clippingStartPoint = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)clipperWithInput:(AKParameter *)input
{
    return [[AKClipper alloc] initWithInput:input];
}

- (void)setLimit:(AKConstant *)limit {
    _limit = limit;
    [self setUpConnections];
}

- (void)setOptionalLimit:(AKConstant *)limit {
    [self setLimit:limit];
}

- (void)setMethod:(AKConstant *)method {
    _method = method;
    [self setUpConnections];
}

- (void)setOptionalMethod:(AKConstant *)method {
    [self setMethod:method];
}

- (void)setClippingStartPoint:(AKConstant *)clippingStartPoint {
    _clippingStartPoint = clippingStartPoint;
    [self setUpConnections];
}

- (void)setOptionalClippingStartPoint:(AKConstant *)clippingStartPoint {
    [self setClippingStartPoint:clippingStartPoint];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _limit, _method, _clippingStartPoint];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"clip("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ clip ", self];
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

    [inputsString appendFormat:@"%@, ", _method];
    
    [inputsString appendFormat:@"%@, ", _limit];
    
    [inputsString appendFormat:@"%@", _clippingStartPoint];
    return inputsString;
}

@end
