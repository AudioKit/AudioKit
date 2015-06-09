//
//  AKPeakingParametricEqualizerFilter.m
//  AudioKit
//
//  Auto-generated on 6/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's pareq:
//  http://www.csounds.com/manual/html/pareq.html
//

#import "AKPeakingParametricEqualizerFilter.h"
#import "AKManager.h"

@implementation AKPeakingParametricEqualizerFilter
{
    AKParameter * _input;
    AKParameter * _centerFrequency;
}

- (instancetype)initWithInput:(AKParameter *)input
              centerFrequency:(AKParameter *)centerFrequency
                    resonance:(AKParameter *)resonance
                         gain:(AKParameter *)gain
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _centerFrequency = centerFrequency;
        _resonance = resonance;
        _gain = gain;
        [self setUpConnections];
}
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
              centerFrequency:(AKParameter *)centerFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _centerFrequency = centerFrequency;
        // Default Values
        _resonance = akp(0.707);
        _gain = akp(1);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)WithInput:(AKParameter *)input
         centerFrequency:(AKParameter *)centerFrequency
{
    return [[AKPeakingParametricEqualizerFilter alloc] initWithInput:input
         centerFrequency:centerFrequency];
}

- (void)setResonance:(AKParameter *)resonance {
    _resonance = resonance;
    [self setUpConnections];
}

- (void)setOptionalResonance:(AKParameter *)resonance {
    [self setResonance:resonance];
}

- (void)setGain:(AKParameter *)gain {
    _gain = gain;
    [self setUpConnections];
}

- (void)setOptionalGain:(AKParameter *)gain {
    [self setGain:gain];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _centerFrequency, _resonance, _gain];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"pareq("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ pareq ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_mode = akp(0);        
    
    if ([_input class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@, ", _input];
    } else {
        [inputsString appendFormat:@"AKAudio(%@), ", _input];
    }

    if ([_centerFrequency class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _centerFrequency];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _centerFrequency];
    }

    if ([_gain class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _gain];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _gain];
    }

    if ([_resonance class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _resonance];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _resonance];
    }

    [inputsString appendFormat:@"%@, ", _mode];
    
    [inputsString appendString:@"tival()"];
    return inputsString;
}

@end
