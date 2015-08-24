//
//  AKDistortion.m
//  AudioKit
//
//  Auto-generated on 7/17/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's distort1:
//  http://www.csounds.com/manual/html/distort1.html
//

#import "AKDistortion.h"
#import "AKManager.h"

@implementation AKDistortion
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
                      pregain:(AKParameter *)pregain
        postiveShapeParameter:(AKParameter *)postiveShapeParameter
       negativeShapeParameter:(AKParameter *)negativeShapeParameter
                     postgain:(AKParameter *)postgain
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _pregain = pregain;
        _postiveShapeParameter = postiveShapeParameter;
        _negativeShapeParameter = negativeShapeParameter;
        _postgain = postgain;
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
        _pregain = akp(1);
        _postiveShapeParameter = akp(0);
        _negativeShapeParameter = akp(0);
        _postgain = akp(1);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)distortionWithInput:(AKParameter *)input
{
    return [[AKDistortion alloc] initWithInput:input];
}

- (void)setPregain:(AKParameter *)pregain {
    _pregain = pregain;
    [self setUpConnections];
}

- (void)setOptionalPregain:(AKParameter *)pregain {
    [self setPregain:pregain];
}

- (void)setPostiveShapeParameter:(AKParameter *)postiveShapeParameter {
    _postiveShapeParameter = postiveShapeParameter;
    [self setUpConnections];
}

- (void)setOptionalPostiveShapeParameter:(AKParameter *)postiveShapeParameter {
    [self setPostiveShapeParameter:postiveShapeParameter];
}

- (void)setNegativeShapeParameter:(AKParameter *)negativeShapeParameter {
    _negativeShapeParameter = negativeShapeParameter;
    [self setUpConnections];
}

- (void)setOptionalNegativeShapeParameter:(AKParameter *)negativeShapeParameter {
    [self setNegativeShapeParameter:negativeShapeParameter];
}

- (void)setPostgain:(AKParameter *)postgain {
    _postgain = postgain;
    [self setUpConnections];
}

- (void)setOptionalPostgain:(AKParameter *)postgain {
    [self setPostgain:postgain];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _pregain, _postiveShapeParameter, _negativeShapeParameter, _postgain];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"distort1("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ distort1 ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_mode = akp(1);
    
    if ([_input class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@, ", _input];
    } else {
        [inputsString appendFormat:@"AKAudio(%@), ", _input];
    }

    if ([_pregain class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _pregain];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _pregain];
    }

    if ([_postgain class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _postgain];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _postgain];
    }

    if ([_postiveShapeParameter class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _postiveShapeParameter];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _postiveShapeParameter];
    }

    if ([_negativeShapeParameter class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _negativeShapeParameter];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _negativeShapeParameter];
    }

    [inputsString appendFormat:@"%@", _mode];
    return inputsString;
}

@end
