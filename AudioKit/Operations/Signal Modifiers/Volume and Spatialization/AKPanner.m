//
//  AKPanner.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Customized by Aurelius Prochazk to add type helpers
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's pan2:
//  http://www.csounds.com/manual/html/pan2.html
//

#import "AKPanner.h"
#import "AKManager.h"

@implementation AKPanner
{
    AKParameter * _input;
}

+ (AKConstant *)panMethodForEqualPower          { return akp(0); }
+ (AKConstant *)panMethodForSquareRoot          { return akp(1); }
+ (AKConstant *)panMethodForLinear              { return akp(2); }
+ (AKConstant *)panMethodForEqualPowerAlternate { return akp(3); }

- (instancetype)initWithInput:(AKParameter *)input
                          pan:(AKParameter *)pan
                    panMethod:(AKConstant *)panMethod
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _pan = pan;
        _panMethod = panMethod;
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
        _pan = akp(0);
        _panMethod = [AKPanner panMethodForEqualPower];
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)pannerWithInput:(AKParameter *)input
{
    return [[AKPanner alloc] initWithInput:input];
}

- (instancetype)initWithPresetDefaultCenteredWithInput:(AKParameter *)input
{
    return [[AKPanner alloc] initWithInput:input];
}


+ (instancetype)presetDefaultCenteredWithInput:(AKParameter *)input;
{
    return [[AKPanner alloc] initWithInput:input];
}

- (instancetype)initWithPresetDefaultHardLeftWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _pan = akp(-1);
        _panMethod = [AKPanner panMethodForEqualPower];
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetDefaultHardLeftWithInput:(AKParameter *)input;
{
    return [[AKPanner alloc] initWithPresetDefaultHardLeftWithInput:input];
}

- (instancetype)initWithPresetDefaultHardRighWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _pan = akp(1);
        _panMethod = [AKPanner panMethodForEqualPower];
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetDefaultHardRighWithInput:(AKParameter *)input;
{
    return [[AKPanner alloc] initWithPresetDefaultHardRighWithInput:input];
}

- (void)setPan:(AKParameter *)pan {
    _pan = pan;
    [self setUpConnections];
}

- (void)setOptionalPan:(AKParameter *)pan {
    [self setPan:pan];
}

- (void)setPanMethod:(AKConstant *)panMethod {
    _panMethod = panMethod;
    [self setUpConnections];
}

- (void)setOptionalPanMethod:(AKConstant *)panMethod {
    [self setPanMethod:panMethod];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _pan, _panMethod];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"pan2("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ pan2 ", self];
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

    [inputsString appendFormat:@"0.5 * (%@+1), ", _pan];
    
    [inputsString appendFormat:@"%@", _panMethod];
    return inputsString;
}

@end
