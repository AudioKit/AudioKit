//
//  AKInverse.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKInverse.h"

@implementation AKInverse {
    AKParameter *_input;
}


- (instancetype)initWIthInput:(AKParameter *)input
{
    self = [super initWithString:[self operationName]];
    
    if (self) {
        _input = input;
        self.state = @"connectable";
        self.dependencies = @[_input];
    }
    return self;
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];
    
    [inlineCSDString appendString:@"akinverse("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];
    
    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    [csdString appendFormat:@"%@ akinverse ", self];
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

- (NSString *)udoString
{
    return @"\n"
    "opcode  akinverse, a, a\n"
    "aIn xin\n"
    "aOut divz 1, aIn, 0\n"
    "xout aOut\n"
    "endop\n";
}
@end
