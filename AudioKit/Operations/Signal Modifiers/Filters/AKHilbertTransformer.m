//
//  AKHilbertTransformer.m
//  AudioKit
//
//  Auto-generated on 3/2/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's akHilbertTransformer:
//  http://www.csounds.com/manual/html/akHilbertTransformer.html
//

#import "AKHilbertTransformer.h"
#import "AKManager.h"

@implementation AKHilbertTransformer
{
    AKParameter * _input;
    AKParameter * _frequency;
}

- (instancetype)initWithInput:(AKParameter *)input
                    frequency:(AKParameter *)frequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _frequency = frequency;
        [self setUpConnections];
}
    return self;
}

+ (instancetype)filterWithInput:(AKParameter *)input
                     frequency:(AKParameter *)frequency
{
    return [[AKHilbertTransformer alloc] initWithInput:input
                     frequency:frequency];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _frequency];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"akHilbertTransformer("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ akHilbertTransformer ", self];
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

    if ([_frequency class] == [AKControl class]) {
        [inputsString appendFormat:@"%@", _frequency];
    } else {
        [inputsString appendFormat:@"AKControl(%@)", _frequency];
    }
return inputsString;
}

- (NSString *)udoString {
    return [NSString stringWithFormat:@"\n"
            "opcode akHilbertTransformer, a, aa\n"
            "ain, aFreq     xin\n"
            "areal, aimag hilbert ain\n"
            "asin oscili 1, aFreq, %@\n"
            "acos oscili 1, aFreq, %@, .25\n"
            "amod1 = areal * acos\n"
            "amod2 = aimag * asin\n"
            "aupshift = (amod1 + amod2) * 0.7\n"
            "xout aupshift\n"
            "endop\n", [AKTable standardSineWave], [AKTable standardSineWave]];
}

@end
