//
//  AKMultitapDelay.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Customized by Aurelius Prochazka adding the addEchoAtTime method
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's multitap:
//  http://www.csounds.com/manual/html/multitap.html
//

#import "AKMultitapDelay.h"
#import "AKManager.h"

@implementation AKMultitapDelay
{
    AKParameter * _input;
    AKConstant * _firstEchoTime;
    AKConstant * _firstEchoGain;
    
    NSMutableArray *timesAndGains;
}

- (instancetype)initWithInput:(AKParameter *)input
                firstEchoTime:(AKConstant *)firstEchoTime
                firstEchoGain:(AKConstant *)firstEchoGain
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _firstEchoTime = firstEchoTime;
        _firstEchoGain = firstEchoGain;
        
        timesAndGains = [[NSMutableArray alloc] init];
        [self addEchoAtTime:firstEchoTime gain:firstEchoGain];

        [self setUpConnections];
    }
    return self;
}

+ (instancetype)delayWithInput:(AKParameter *)input
                firstEchoTime:(AKConstant *)firstEchoTime
                firstEchoGain:(AKConstant *)firstEchoGain
{
    return [[AKMultitapDelay alloc] initWithInput:input
                firstEchoTime:firstEchoTime
                firstEchoGain:firstEchoGain];
}

- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input];
}

- (void)addEchoAtTime:(AKConstant *)time gain:(AKConstant *)gain
{
    [timesAndGains addObject:@[time, gain]];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"multitap("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ multitap ", self];
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

    
    NSMutableArray *flattenedTimesAndGains = [[NSMutableArray alloc] init];
    for (NSArray *timeAndGain in timesAndGains) {
        [flattenedTimesAndGains addObject:[timeAndGain componentsJoinedByString:@", "]];
    }
    
    [inputsString appendFormat:@"%@", [flattenedTimesAndGains componentsJoinedByString:@", "]];

    return inputsString;
}

@end
