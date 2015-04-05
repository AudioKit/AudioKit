//
//  AKDifference.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKDifference.h"
#import "AKSum.h"

@implementation AKDifference {
    AKParameter *_minuend;
    AKParameter *_subtrahend;
}

- (instancetype)initWithInput:(AKParameter *)minuend minus:(AKParameter *)subtrahend
{
    self = [super initWithString:[self operationName]];
    
    if (self) {
        _minuend = minuend;
        _subtrahend = subtrahend;
        self.state = @"connectable";
        self.dependencies = @[_minuend, _subtrahend];
    }
    return self;
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];
    
    [inlineCSDString appendString:@"akdifference("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];
    
    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    [csdString appendFormat:@"%@ akdifference ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];
    
    
    if ([_minuend class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@, ", _minuend];
    } else {
        [inputsString appendFormat:@"AKAudio(%@), ", _minuend];
    }
    
    if ([_subtrahend class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@", _subtrahend];
    } else {
        [inputsString appendFormat:@"AKAudio(%@)", _subtrahend];
    }

    return inputsString;
}

- (NSString *)udoString
{
    return @"\n"
    "opcode  akdifference, a, aa\n"
    "aMinuend, aSubtrahend xin\n"
    "aDifference sum aMinuend, -aSubtrahend\n"
    "xout aDifference\n"
    "endop\n";
}
@end
