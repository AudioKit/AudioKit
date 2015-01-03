//
//  AKVCOscillator.m
//  AudioKit
//
//  Auto-generated on 1/2/15.
//  Customized by Aurelius Prochazka on 1/2/15 to add tival() to waveformtype
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's vco2:
//  http://www.csounds.com/manual/html/vco2.html
//

#import "AKVCOscillator.h"
#import "AKManager.h"

@implementation AKVCOscillator

- (instancetype)initWithWaveformType:(AKVCOscillatorWaveformType)waveformType
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
        _waveformType = AKVCOscillatorWaveformTypeSawtooth;
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

- (void)setOptionalWaveformType:(AKVCOscillatorWaveformType)waveformType {
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

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_phase = akp(0);        
    [csdString appendFormat:@"%@ vco2 ", self];

    if ([_amplitude class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _amplitude];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _amplitude];
    }

    if ([_frequency class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _frequency];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _frequency];
    }

    [csdString appendFormat:@"tival()+%@, ", akpi(_waveformType)];
    
    if ([_pulseWidth class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _pulseWidth];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _pulseWidth];
    }

    if ([_phase class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _phase];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _phase];
    }

    [csdString appendFormat:@"%@", _bandwidth];
    return csdString;
}

@end
