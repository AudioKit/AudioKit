//
//  AKVariableDelay.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's vdelay3:
//  http://www.csounds.com/manual/html/vdelay3.html
//

#import "AKVariableDelay.h"
#import "AKManager.h"

@implementation AKVariableDelay
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
                    delayTime:(AKParameter *)delayTime
             maximumDelayTime:(AKConstant *)maximumDelayTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _delayTime = delayTime;
        _maximumDelayTime = maximumDelayTime;
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
        _delayTime = akp(0);
        _maximumDelayTime = akp(5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)delayWithInput:(AKParameter *)input
{
    return [[AKVariableDelay alloc] initWithInput:input];
}

- (void)setDelayTime:(AKParameter *)delayTime {
    _delayTime = delayTime;
    [self setUpConnections];
}

- (void)setOptionalDelayTime:(AKParameter *)delayTime {
    [self setDelayTime:delayTime];
}

- (void)setMaximumDelayTime:(AKConstant *)maximumDelayTime {
    _maximumDelayTime = maximumDelayTime;
    [self setUpConnections];
}

- (void)setOptionalMaximumDelayTime:(AKConstant *)maximumDelayTime {
    [self setMaximumDelayTime:maximumDelayTime];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _delayTime, _maximumDelayTime];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"vdelay3("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ vdelay3 ", self];
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

    if ([_delayTime class] == [AKAudio class]) {
        [inputsString appendFormat:@"(1000 * %@), ", _delayTime];
    } else {
        [inputsString appendFormat:@"AKAudio((1000 * %@)), ", _delayTime];
    }

    [inputsString appendFormat:@"(1000 * %@)", _maximumDelayTime];
    return inputsString;
}

@end
