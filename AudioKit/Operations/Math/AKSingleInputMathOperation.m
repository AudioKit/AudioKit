//
//  AKSingleInputMathOperation.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKSingleInputMathOperation.h"

@implementation AKSingleInputMathOperation {
    NSString *_function;
    AKParameter *_input;
}

- (instancetype)initWithFunctionString:(NSString *)function
                                 input:(AKParameter *)input
{
    self = [super initWithString:[function capitalizedString]];
    
    if (self) {
        _function = function;
        _input = input;
        self.state = @"connectable";
        self.dependencies = @[_input];
    }
    return self;
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];
    
    [inlineCSDString appendFormat:@"ak%@(", _function];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];
    
    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    [csdString appendFormat:@"%@ ak%@ ", self, _function];
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
    return [NSString stringWithFormat:@"\n"
            "opcode  ak%@, a, a\n"
            "aIn xin\n"
            "aOut %@ aIn\n"
            "xout aOut\n"
            "endop\n", _function, _function];
}

@end
