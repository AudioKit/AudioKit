//
//  AKVCOscillator.m
//  AudioKit
//
//  Auto-generated on 12/25/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's vco2:
//  http://www.csounds.com/manual/html/vco2.html
//

#import "AKVCOscillator.h"
#import "AKManager.h"

@implementation AKVCOscillator

- (instancetype)initWithWaveformType:(AKVCOscillatorWaveformType)waveformType
                           bandwidth:(AKConstant *)bandwidth
                           frequency:(AKParameter *)frequency
                           amplitude:(AKParameter *)amplitude
                          pulseWidth:(AKParameter *)pulseWidth
                               phase:(AKParameter *)phase
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _waveformType = waveformType;
        _bandwidth = bandwidth;
        _frequency = frequency;
        _amplitude = amplitude;
        _pulseWidth = pulseWidth;
        _phase = phase;
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
        _frequency = akp(440);
        _amplitude = akp(1);
        _pulseWidth = akp(0);
        _phase = akp(0);
    }
    return self;
}

+ (instancetype)audio
{
    return [[AKVCOscillator alloc] init];
}

- (void)setOptionalWaveformType:(AKVCOscillatorWaveformType)waveformType {
    _waveformType = waveformType;
}
- (void)setOptionalBandwidth:(AKConstant *)bandwidth {
    _bandwidth = bandwidth;
}
- (void)setOptionalFrequency:(AKParameter *)frequency {
    _frequency = frequency;
}
- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
}
- (void)setOptionalPulseWidth:(AKParameter *)pulseWidth {
    _pulseWidth = pulseWidth;
}
- (void)setOptionalPhase:(AKParameter *)phase {
    _phase = phase;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ vco2 ", self];

    if ([_amplitude isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _amplitude];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _amplitude];
    }

    if ([_frequency isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _frequency];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _frequency];
    }

    [csdString appendFormat:@"%@, ", akpi(_waveformType)];
    
    if ([_pulseWidth isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _pulseWidth];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _pulseWidth];
    }

    if ([_phase isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _phase];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _phase];
    }

    [csdString appendFormat:@"%@", _bandwidth];
    return csdString;
}

@end
