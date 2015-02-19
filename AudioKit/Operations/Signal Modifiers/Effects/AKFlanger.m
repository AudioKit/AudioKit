//
//  AKFlanger.m
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's flanger:
//  http://www.csounds.com/manual/html/flanger.html
//

#import "AKFlanger.h"
#import "AKManager.h"

@implementation AKFlanger
{
    AKParameter * _input;
    AKParameter * _delayTime;
}

- (instancetype)initWithInput:(AKParameter *)input
                    delayTime:(AKParameter *)delayTime
                     feedback:(AKParameter *)feedback
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _delayTime = delayTime;
        _feedback = feedback;
        [self setUpConnections];
}
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
                    delayTime:(AKParameter *)delayTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _delayTime = delayTime;
        // Default Values
        _feedback = akp(0);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)effectWithInput:(AKParameter *)input
                     delayTime:(AKParameter *)delayTime
{
    return [[AKFlanger alloc] initWithInput:input
                     delayTime:delayTime];
}

- (void)setFeedback:(AKParameter *)feedback {
    _feedback = feedback;
    [self setUpConnections];
}

- (void)setOptionalFeedback:(AKParameter *)feedback {
    [self setFeedback:feedback];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _delayTime, _feedback];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"flanger("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ flanger ", self];
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
        [inputsString appendFormat:@"%@, ", _delayTime];
    } else {
        [inputsString appendFormat:@"AKAudio(%@), ", _delayTime];
    }

    if ([_feedback class] == [AKControl class]) {
        [inputsString appendFormat:@"%@", _feedback];
    } else {
        [inputsString appendFormat:@"AKControl(%@)", _feedback];
    }
return inputsString;
}

@end
