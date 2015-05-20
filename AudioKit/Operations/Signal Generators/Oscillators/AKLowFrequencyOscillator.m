//
//  AKLowFrequencyOscillator.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Customized by Aurelius Prochazka adding type helpers and more
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's lfo:
//  http://www.csounds.com/manual/html/lfo.html
//

#import "AKLowFrequencyOscillator.h"
#import "AKManager.h"

@implementation AKLowFrequencyOscillator

+ (AKConstant *)waveformTypeForSine           { return akp(0); }
+ (AKConstant *)waveformTypeForTriangle       { return akp(1); }
+ (AKConstant *)waveformTypeForBipolarSquare  { return akp(2); }
+ (AKConstant *)waveformTypeForUnipolarSquare { return akp(3); }
+ (AKConstant *)waveformTypeForSawtooth       { return akp(4); }
+ (AKConstant *)waveformTypeForDownSawtooth   { return akp(5); }

- (instancetype)initWithWaveformType:(AKConstant *)waveFormType
                           frequency:(AKParameter *)frequency
                           amplitude:(AKParameter *)amplitude
{

    self = [super initWithString:[self operationName]];
    if (self) {
        _waveformType = waveFormType;
        _frequency = frequency;
        _amplitude = amplitude;
        [self setUpConnections];
}
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _waveformType = [AKLowFrequencyOscillator waveformTypeForSine];
        _frequency = akp(110);
        _amplitude = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)oscillator
{
    return [[AKLowFrequencyOscillator alloc] init];
}


- (void)setOptionalWaveformType:(AKConstant *)waveformType {
    _waveformType = waveformType;
}

- (void)setFrequency:(AKParameter *)frequency {
    _frequency = frequency;
    [self setUpConnections];
}

- (void)setOptionalFrequency:(AKParameter *)frequency {
    [self setFrequency:frequency];
}

- (void)setAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
    [self setUpConnections];
}

- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    [self setAmplitude:amplitude];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_waveformType, _frequency, _amplitude];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"lfo("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ lfo ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    
    if ([_amplitude class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _amplitude];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _amplitude];
    }

    if ([_frequency class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _frequency];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _frequency];
    }

    [inputsString appendFormat:@"%@", _waveformType];
    return inputsString;
}

@end
