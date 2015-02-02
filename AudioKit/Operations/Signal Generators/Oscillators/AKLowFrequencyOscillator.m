//
//  AKLowFrequencyOscillator.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
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
        _amplitude = akp(1);
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
- (void)setOptionalFrequency:(AKParameter *)frequency {
    _frequency = frequency;
}
- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    [csdString appendFormat:@"%@ lfo ", self];
    
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
    
    [csdString appendFormat:@"%@", _waveformType];
    return csdString;
}

@end
