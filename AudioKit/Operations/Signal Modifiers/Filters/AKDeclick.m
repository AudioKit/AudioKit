//
//  AKDeclick.m
//  AudioKit
//
//  Auto-generated on 2/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's declick:
//  http://www.csounds.com/manual/html/declick.html
//

#import "AKDeclick.h"
#import "AKManager.h"

@implementation AKDeclick
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        [self setUpConnections];
}
    return self;
}

+ (instancetype)WithInput:(AKParameter *)input
{
    return [[AKDeclick alloc] initWithInput:input];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"declick("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ declick ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    
    if ([_input class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@", _input];
    } else {
        [inputsString appendFormat:@"AKAudio(%@)", _input];
    }
return inputsString;
}

- (NSString *)udoString {
    return @"\n"
    "opcode declick, a, a\n"
    "ain     xin\n"
    "aenv    linseg 0, 0.02, 1, p3 - 0.05, 1, 0.02, 0, 0.01, 0\n"
    "xout ain * aenv         ; apply envelope and write output\n"
    "endop\n";
}


@end
