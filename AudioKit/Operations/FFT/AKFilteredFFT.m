//
//  AKFilteredFFT.m
//  AudioKit
//
//  Auto-generated on 9/12/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's pvsfilter:
//  http://www.csounds.com/manual/html/pvsfilter.html
//

#import "AKFilteredFFT.h"
#import "AKManager.h"

@implementation AKFilteredFFT
{
    AKFSignal * _input;
    AKFSignal * _amplitude;
    AKParameter * _depth;
}

- (instancetype)initWithInput:(AKFSignal *)input
                    amplitude:(AKFSignal *)amplitude
                        depth:(AKParameter *)depth
                         gain:(AKConstant *)gain
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _amplitude = amplitude;
        _depth = depth;
        _gain = gain;
        [self setUpConnections];
    }
    return self;
}

- (instancetype)initWithInput:(AKFSignal *)input
                    amplitude:(AKFSignal *)amplitude
                        depth:(AKParameter *)depth
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _amplitude = amplitude;
        _depth = depth;
        // Default Values
        _gain = akp(1.0);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)filteredFFTWithInput:(AKFSignal *)input
                           amplitude:(AKFSignal *)amplitude
                               depth:(AKParameter *)depth
{
    return [[AKFilteredFFT alloc] initWithInput:input
                                      amplitude:amplitude
                                          depth:depth];
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
    self.dependencies = @[_input, _amplitude, _depth, _gain];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"pvsfilter("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ pvsfilter ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    
    [inputsString appendFormat:@"%@, ", _input];
    
    [inputsString appendFormat:@"%@, ", _amplitude];
    
    if ([_depth class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _depth];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _depth];
    }

    [inputsString appendFormat:@"%@", _gain];
    return inputsString;
}

@end
