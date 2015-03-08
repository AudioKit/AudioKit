//
//  AKGranularSynthesizer.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Customized by Aurelius Prochazka to deal with window waveform.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's grain3:
//  http://www.csounds.com/manual/html/grain3.html
//

#import "AKGranularSynthesizer.h"
#import "AKManager.h"
#import "AKWindowTableGenerator.h"

@implementation AKGranularSynthesizer
{
    AKTable * _grainWaveform;
    AKParameter * _frequency;
}

- (instancetype)initWithGrainWaveform:(AKTable *)grainWaveform
                            frequency:(AKParameter *)frequency
                       windowWaveform:(AKTable *)windowWaveform
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
        [self setUpConnections];
    }
    return self;
}

- (instancetype)initWithGrainWaveform:(AKTable *)grainWaveform
                            frequency:(AKParameter *)frequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _grainWaveform = grainWaveform;
        _frequency = frequency;
        // Default Values
        _windowWaveform = [[AKTable alloc] initWithSize:4096];
        [_windowWaveform populateTableWithGenerator:[AKWindowTableGenerator hannWindow]];
        _duration = akp(0.2);
        _density = akp(200);
        _maximumOverlappingGrains = akp(200);
        _frequencyVariation = akp(0);
        _frequencyVariationDistribution = akp(0);
        _phase = akp(0.5);
        _startPhaseVariation = akp(0.5);
        _prpow = akp(0);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)WithGrainWaveform:(AKTable *)grainWaveform
                        frequency:(AKParameter *)frequency
{
    return [[AKGranularSynthesizer alloc] initWithGrainWaveform:grainWaveform
                                                      frequency:frequency];
}

- (void)setWindowWaveform:(AKTable *)windowWaveform {
    _windowWaveform = windowWaveform;
    [self setUpConnections];
}

- (void)setOptionalWindowWaveform:(AKTable *)windowWaveform {
    [self setWindowWaveform:windowWaveform];
}

- (void)setDuration:(AKParameter *)duration {
    _duration = duration;
    [self setUpConnections];
}

- (void)setOptionalDuration:(AKParameter *)duration {
    [self setDuration:duration];
}

- (void)setDensity:(AKParameter *)density {
    _density = density;
    [self setUpConnections];
}

- (void)setOptionalDensity:(AKParameter *)density {
    [self setDensity:density];
}

- (void)setMaximumOverlappingGrains:(AKConstant *)maximumOverlappingGrains {
    _maximumOverlappingGrains = maximumOverlappingGrains;
    [self setUpConnections];
}

- (void)setOptionalMaximumOverlappingGrains:(AKConstant *)maximumOverlappingGrains {
    [self setMaximumOverlappingGrains:maximumOverlappingGrains];
}

- (void)setFrequencyVariation:(AKParameter *)frequencyVariation {
    _frequencyVariation = frequencyVariation;
    [self setUpConnections];
}

- (void)setOptionalFrequencyVariation:(AKParameter *)frequencyVariation {
    [self setFrequencyVariation:frequencyVariation];
}

- (void)setFrequencyVariationDistribution:(AKParameter *)frequencyVariationDistribution {
    _frequencyVariationDistribution = frequencyVariationDistribution;
    [self setUpConnections];
}

- (void)setOptionalFrequencyVariationDistribution:(AKParameter *)frequencyVariationDistribution {
    [self setFrequencyVariationDistribution:frequencyVariationDistribution];
}

- (void)setPhase:(AKParameter *)phase {
    _phase = phase;
    [self setUpConnections];
}

- (void)setOptionalPhase:(AKParameter *)phase {
    [self setPhase:phase];
}

- (void)setStartPhaseVariation:(AKParameter *)startPhaseVariation {
    _startPhaseVariation = startPhaseVariation;
    [self setUpConnections];
}

- (void)setOptionalStartPhaseVariation:(AKParameter *)startPhaseVariation {
    [self setStartPhaseVariation:startPhaseVariation];
}

- (void)setPrpow:(AKParameter *)prpow {
    _prpow = prpow;
    [self setUpConnections];
}

- (void)setOptionalPrpow:(AKParameter *)prpow {
    [self setPrpow:prpow];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_frequency, _duration, _density, _maximumOverlappingGrains, _frequencyVariation, _frequencyVariationDistribution, _phase, _startPhaseVariation, _prpow];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];
    
    [inlineCSDString appendString:@"grain3("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];
    
    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    [csdString appendFormat:@"%@ grain3 ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    
    NSMutableString *inputsString = [[NSMutableString alloc] init];
    
    // Constant Values
    AKConstant *_mode = akp(0);
    AKConstant *_seed = akp(0);
    
    if ([_frequency class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _frequency];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _frequency];
    }
    
    if ([_phase class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _phase];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _phase];
    }
    
    if ([_frequencyVariation class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _frequencyVariation];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _frequencyVariation];
    }
    
    if ([_startPhaseVariation class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _startPhaseVariation];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _startPhaseVariation];
    }
    
    if ([_duration class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _duration];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _duration];
    }
    
    if ([_density class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _density];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _density];
    }
    
    [inputsString appendFormat:@"%@, ", _maximumOverlappingGrains];
    
    if ([_grainWaveform class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _grainWaveform];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _grainWaveform];
    }
    
    [inputsString appendFormat:@"%@, ", _windowWaveform];
    
    if ([_frequencyVariationDistribution class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _frequencyVariationDistribution];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _frequencyVariationDistribution];
    }
    
    if ([_prpow class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _prpow];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _prpow];
    }
    
    [inputsString appendFormat:@"%@, ", _seed];
    
    [inputsString appendFormat:@"%@", _mode];
    return inputsString;
}

@end
