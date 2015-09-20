//
//  AKMaskedFFT.m
//  AudioKit
//
//  Auto-generated on 9/20/15.
//  Customised by Daniel Clelland on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's pvsmaska:
//  http://www.csounds.com/manual/html/pvsmaska.html
//

#import "AKMaskedFFT.h"
#import "AKManager.h"

@implementation AKMaskedFFT
{
    AKFSignal * _input;
    AKTable * _amplitudeTable;
    AKParameter * _depth;
}

- (instancetype)initWithInput:(AKFSignal *)input
               amplitudeTable:(AKTable *)amplitudeTable
                        depth:(AKParameter *)depth
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _amplitudeTable = amplitudeTable;
        _depth = depth;
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)maskedFFTWithInput:(AKFSignal *)input
                    amplitudeTable:(AKTable *)amplitudeTable
                             depth:(AKParameter *)depth
{
    return [[AKMaskedFFT alloc] initWithInput:input
                               amplitudeTable:amplitudeTable
                                        depth:depth];
}

- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _depth];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"pvsmaska("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}

- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ pvsmaska ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    
    [inputsString appendFormat:@"%@, ", _input];
    
    [inputsString appendFormat:@"%@, ", _amplitudeTable];
    
    if ([_depth class] == [AKControl class]) {
        [inputsString appendFormat:@"%@", _depth];
    } else {
        [inputsString appendFormat:@"AKControl(%@)", _depth];
    }
    return inputsString;
}

@end
