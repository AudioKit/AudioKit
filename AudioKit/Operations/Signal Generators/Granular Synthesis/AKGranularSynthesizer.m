//
//  AKGranularSynthesizer.m
//  AudioKit
//
//  Auto-generated on 1/28/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's grain3:
//  http://www.csounds.com/manual/html/grain3.html
//

#import "AKGranularSynthesizer.h"
#import "AKManager.h"

@implementation AKGranularSynthesizer
{
    AKParameter * _grainWaveform;
    AKParameter * _frequency;
}

- (instancetype)initWithGrainWaveform:(AKParameter *)grainWaveform
                            frequency:(AKParameter *)frequency
                       windowWaveform:(AKWindow *)windowWaveform
                             duration:(AKParameter *)duration
                              density:(AKParameter *)density
             maximumOverlappingGrains:(AKConstant *)maximumOverlappingGrains
                   frequencyVariation:(AKParameter *)frequencyVariation
       frequencyVariationDistribution:(AKParameter *)frequencyVariationDistribution
                                phase:(AKParameter *)phase
                  startPhaseVariation:(AKParameter *)startPhaseVariation
                                prpow:(AKParameter *)prpow
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _grainWaveform = grainWaveform;
        _frequency = frequency;
        _windowWaveform = windowWaveform;
        _duration = duration;
        _density = density;
        _maximumOverlappingGrains = maximumOverlappingGrains;
        _frequencyVariation = frequencyVariation;
        _frequencyVariationDistribution = frequencyVariationDistribution;
        _phase = phase;
        _startPhaseVariation = startPhaseVariation;
        _prpow = prpow;
    }
    return self;
}

- (instancetype)initWithGrainWaveform:(AKParameter *)grainWaveform
                            frequency:(AKParameter *)frequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _grainWaveform = grainWaveform;
        _frequency = frequency;
        // Default Values
        _windowWaveform = [[AKWindow alloc] initWithType:AKWindowTableTypeHamming];
        _duration = akp(0.2);
        _density = akp(200);
        _maximumOverlappingGrains = akp(200);
        _frequencyVariation = akp(0);
        _frequencyVariationDistribution = akp(0);
        _phase = akp(0.5);
        _startPhaseVariation = akp(0.5);
        _prpow = akp(0);
    }
    return self;
}

+ (instancetype)WithGrainWaveform:(AKParameter *)grainWaveform
                       frequency:(AKParameter *)frequency
{
    return [[AKGranularSynthesizer alloc] initWithGrainWaveform:grainWaveform
                       frequency:frequency];
}

- (void)setOptionalWindowWaveform:(AKWindow *)windowWaveform {
    _windowWaveform = windowWaveform;
}
- (void)setOptionalDuration:(AKParameter *)duration {
    _duration = duration;
}
- (void)setOptionalDensity:(AKParameter *)density {
    _density = density;
}
- (void)setOptionalMaximumOverlappingGrains:(AKConstant *)maximumOverlappingGrains {
    _maximumOverlappingGrains = maximumOverlappingGrains;
}
- (void)setOptionalFrequencyVariation:(AKParameter *)frequencyVariation {
    _frequencyVariation = frequencyVariation;
}
- (void)setOptionalFrequencyVariationDistribution:(AKParameter *)frequencyVariationDistribution {
    _frequencyVariationDistribution = frequencyVariationDistribution;
}
- (void)setOptionalPhase:(AKParameter *)phase {
    _phase = phase;
}
- (void)setOptionalStartPhaseVariation:(AKParameter *)startPhaseVariation {
    _startPhaseVariation = startPhaseVariation;
}
- (void)setOptionalPrpow:(AKParameter *)prpow {
    _prpow = prpow;
}

- (NSString *)stringForCSD {
    [[[[AKManager sharedManager] orchestra] functionTables] addObject:_windowWaveform];
    NSMutableString *csdString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_mode = akp(0);        
    AKConstant *_seed = akp(0);        
    [csdString appendFormat:@"%@ grain3 ", self];

    if ([_frequency class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _frequency];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _frequency];
    }

    if ([_phase class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _phase];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _phase];
    }

    if ([_frequencyVariation class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _frequencyVariation];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _frequencyVariation];
    }

    if ([_startPhaseVariation class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _startPhaseVariation];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _startPhaseVariation];
    }

    if ([_duration class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _duration];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _duration];
    }

    if ([_density class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _density];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _density];
    }

    [csdString appendFormat:@"%@, ", _maximumOverlappingGrains];
    
    if ([_grainWaveform class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _grainWaveform];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _grainWaveform];
    }

    [csdString appendFormat:@"%@, ", _windowWaveform];
    
    if ([_frequencyVariationDistribution class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _frequencyVariationDistribution];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _frequencyVariationDistribution];
    }

    if ([_prpow class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _prpow];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _prpow];
    }

    [csdString appendFormat:@"%@, ", _seed];
    
    [csdString appendFormat:@"%@", _mode];
    return csdString;
}

@end
