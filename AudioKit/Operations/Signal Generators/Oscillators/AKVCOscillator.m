//
//  AKVCOscillator.m
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Customized by Aurelius Prochazka  to add tival() to waveformtype and class helpers for waveform type
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
        _bandwidth = bandwidth;
        _pulseWidth = pulseWidth;
        _frequency = frequency;
        _amplitude = amplitude;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _waveformType = [AKVCOscillator waveformTypeForSawtooth];
        _bandwidth = akp(0.5);
        _pulseWidth = akp(0);
        _frequency = akp(440);
        _amplitude = akp(1);
    }
    return self;
}

+ (instancetype)oscillator
{
    return [[AKVCOscillator alloc] init];
}

- (void)setOptionalWaveformType:(AKConstant *)waveformType {
    _waveformType = waveformType;
}
- (void)setOptionalBandwidth:(AKConstant *)bandwidth {
    _bandwidth = bandwidth;
}
- (void)setOptionalPulseWidth:(AKParameter *)pulseWidth {
    _pulseWidth = pulseWidth;
}
- (void)setOptionalFrequency:(AKParameter *)frequency {
    _frequency = frequency;
}
- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
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
