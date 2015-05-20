//
//  AKVCOscillator.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Customized by Aurelius Prochazka to add tival() to waveformtype and class helpers for waveform type
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's vco2:
//  http://www.csounds.com/manual/html/vco2.html
//

#import "AKVCOscillator.h"
#import "AKManager.h"

@implementation AKVCOscillator

+ (AKConstant *)waveformTypeForSawtooth           { return akp(0);  }
+ (AKConstant *)waveformTypeForSquareWithPWM      { return akp(2);  }
+ (AKConstant *)waveformTypeForTriangleWithRamp   { return akp(4);  }
+ (AKConstant *)waveformTypeForUnnormalizedPulse  { return akp(6);  }
+ (AKConstant *)waveformTypeForIntegratedSawtooth { return akp(8);  }
+ (AKConstant *)waveformTypeForSquare             { return akp(10); }
+ (AKConstant *)waveformTypeForTriangle           { return akp(12); }

- (instancetype)initWithWaveformType:(AKConstant *)waveformType
                           bandwidth:(AKConstant *)bandwidth
                          pulseWidth:(AKParameter *)pulseWidth
                           frequency:(AKParameter *)frequency
                           amplitude:(AKParameter *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _waveformType = waveformType;
        _bandwidth  = bandwidth;
        _pulseWidth = pulseWidth;
        _frequency  = frequency;
        _amplitude  = amplitude;
        [self setUpConnections];
}
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _waveformType = [AKVCOscillator waveformTypeForSawtooth];
        _bandwidth  = akp(0.5);
        _pulseWidth = akp(0);
        _frequency  = akp(440);
        _amplitude  = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)oscillator
{
    return [[AKVCOscillator alloc] init];
}

+ (instancetype)presetSawtoothOscillator
{
    return [[AKVCOscillator alloc] init];
}


- (instancetype)initWithSquareWithPWMOscillator
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _waveformType = [AKVCOscillator waveformTypeForSquareWithPWM];
        _bandwidth  = akp(0.5);
        _pulseWidth = akp(0.5);
        _frequency  = akp(440);
        _amplitude  = akp(0.5);
        [self setUpConnections];
    }
    return self;
}


+ (instancetype)presetSquareWithPWMOscillator
{
    return [[AKVCOscillator alloc] initWithSquareWithPWMOscillator];
}


- (instancetype)initWithUnnormalizedPulseOscillator
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _waveformType = [AKVCOscillator waveformTypeForUnnormalizedPulse];
        _bandwidth  = akp(0.5);
        _pulseWidth = akp(0);
        _frequency  = akp(440);
        _amplitude  = akp(0.1);
        [self setUpConnections];
    }
    return self;
}


+ (instancetype)presetUnnormalizedPulseOscillator
{
    return [[AKVCOscillator alloc] initWithUnnormalizedPulseOscillator];
}

- (instancetype)initWithIntegratedSawtoothOscillator
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _waveformType = [AKVCOscillator waveformTypeForIntegratedSawtooth];
        _bandwidth  = akp(0.5);
        _pulseWidth = akp(0);
        _frequency  = akp(440);
        _amplitude  = akp(0.5);
        [self setUpConnections];
    }
    return self;
}


+ (instancetype)presetIntegratedSawtoothOscillator
{
    return [[AKVCOscillator alloc] initWithIntegratedSawtoothOscillator];
}

- (instancetype)initWithSquareOscillator
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _waveformType = [AKVCOscillator waveformTypeForSquare];
        _bandwidth  = akp(0.5);
        _pulseWidth = akp(0);
        _frequency  = akp(440);
        _amplitude  = akp(0.5);
        [self setUpConnections];
    }
    return self;
}


+ (instancetype)presetSquareOscillator
{
    return [[AKVCOscillator alloc] initWithSquareOscillator];
}

- (instancetype)initWithTriangleOscillator
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _waveformType = [AKVCOscillator waveformTypeForTriangle];
        _bandwidth  = akp(0.5);
        _pulseWidth = akp(0);
        _frequency  = akp(440);
        _amplitude  = akp(0.5);
        [self setUpConnections];
    }
    return self;
}


+ (instancetype)presetTriangleOscillator
{
    return [[AKVCOscillator alloc] initWithTriangleOscillator];
}

- (void)setWaveformType:(AKConstant *)waveformType {
    _waveformType = waveformType;
    [self setUpConnections];
}

- (void)setOptionalWaveformType:(AKConstant *)waveformType {
    [self setWaveformType:waveformType];
}

- (void)setBandwidth:(AKConstant *)bandwidth {
    _bandwidth = bandwidth;
    [self setUpConnections];
}

- (void)setOptionalBandwidth:(AKConstant *)bandwidth {
    [self setBandwidth:bandwidth];
}

- (void)setPulseWidth:(AKParameter *)pulseWidth {
    _pulseWidth = pulseWidth;
    [self setUpConnections];
}

- (void)setOptionalPulseWidth:(AKParameter *)pulseWidth {
    [self setPulseWidth:pulseWidth];
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
    self.dependencies = @[_waveformType, _bandwidth, _pulseWidth, _frequency, _amplitude];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"vco2("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ vco2 ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_phase = akp(0);        
    
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

    [inputsString appendFormat:@"tival()+%@, ", _waveformType];
    
    if ([_pulseWidth class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _pulseWidth];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _pulseWidth];
    }

    if ([_phase class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _phase];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _phase];
    }

    [inputsString appendFormat:@"%@", _bandwidth];
    return inputsString;
}

@end
