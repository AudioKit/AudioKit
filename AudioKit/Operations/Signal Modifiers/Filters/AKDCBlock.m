//
//  AKDCBlock.m
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's dcblock:
//  http://www.csounds.com/manual/html/dcblock.html
//

#import "AKDCBlock.h"
#import "AKManager.h"

@implementation AKDCBlock
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
                         gain:(AKConstant *)gain
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _gain = gain;
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
        _gain = akp(0.99);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)filterWithInput:(AKParameter *)input
{
    return [[AKDCBlock alloc] initWithInput:input];
}

- (void)setGain:(AKConstant *)gain {
    _gain = gain;
    [self setUpConnections];
}

- (void)setOptionalGain:(AKConstant *)gain {
    [self setGain:gain];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _gain];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"dcblock("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ dcblock ", self];
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

    [inputsString appendFormat:@"%@", _gain];
    return inputsString;
}

@end
