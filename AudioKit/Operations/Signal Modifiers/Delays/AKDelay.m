//
//  AKDelay.m
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Customized by Aurelius Prochazka to add akdelay udo.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's delay:
//  http://www.csounds.com/manual/html/delay.html
//

#import "AKDelay.h"
#import "AKManager.h"

@implementation AKDelay
{
    AKParameter * _input;
    AKConstant * _delayTime;
}

- (instancetype)initWithInput:(AKParameter *)input
                    delayTime:(AKConstant *)delayTime
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
                    delayTime:(AKConstant *)delayTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _delayTime = delayTime;
        // Default Values
        _feedback = akp(0.0);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)delayWithInput:(AKParameter *)input
                    delayTime:(AKConstant *)delayTime
{
    return [[AKDelay alloc] initWithInput:input
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

    [inlineCSDString appendString:@"akdelay("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ akdelay ", self];
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

    if ([_feedback class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _feedback];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _feedback];
    }

    [inputsString appendFormat:@"%@", _delayTime];
    return inputsString;
}

- (NSString *)udoString
{
    return @"\n"
    "opcode  akdelay, a, aki\n"
    "aIn, kFeedback, iTime xin\n"
    "aOut init 0\n"
    "aOut delay aIn + (aOut*kFeedback), iTime\n"
    "xout      aOut\n"
    "endop\n";
}

@end
