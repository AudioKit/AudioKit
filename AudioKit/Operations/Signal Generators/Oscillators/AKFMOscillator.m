//
//  AKFMOscillator.m
//  AudioKit
//
//  Auto-generated on 3/2/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's foscili:
//  http://www.csounds.com/manual/html/foscili.html
//

#import "AKFMOscillator.h"
#import "AKManager.h"

@implementation AKFMOscillator

- (instancetype)initWithWaveform:(AKTable *)waveform
                   baseFrequency:(AKParameter *)baseFrequency
               carrierMultiplier:(AKParameter *)carrierMultiplier
            modulatingMultiplier:(AKParameter *)modulatingMultiplier
                 modulationIndex:(AKParameter *)modulationIndex
                       amplitude:(AKParameter *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _waveform = waveform;
        _baseFrequency = baseFrequency;
        _carrierMultiplier = carrierMultiplier;
        _modulatingMultiplier = modulatingMultiplier;
        _modulationIndex = modulationIndex;
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
        _waveform = [AKTable standardSineWave];
    
        _baseFrequency = akp(440);
        _carrierMultiplier = akp(1);
        _modulatingMultiplier = akp(1);
        _modulationIndex = akp(1);
        _amplitude = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)oscillator
{
    return [[AKFMOscillator alloc] init];
}

- (void)setWaveform:(AKTable *)waveform {
    _waveform = waveform;
    [self setUpConnections];
}

- (void)setOptionalWaveform:(AKTable *)waveform {
    [self setWaveform:waveform];
}

- (void)setBaseFrequency:(AKParameter *)baseFrequency {
    _baseFrequency = baseFrequency;
    [self setUpConnections];
}

- (void)setOptionalBaseFrequency:(AKParameter *)baseFrequency {
    [self setBaseFrequency:baseFrequency];
}

- (void)setCarrierMultiplier:(AKParameter *)carrierMultiplier {
    _carrierMultiplier = carrierMultiplier;
    [self setUpConnections];
}

- (void)setOptionalCarrierMultiplier:(AKParameter *)carrierMultiplier {
    [self setCarrierMultiplier:carrierMultiplier];
}

- (void)setModulatingMultiplier:(AKParameter *)modulatingMultiplier {
    _modulatingMultiplier = modulatingMultiplier;
    [self setUpConnections];
}

- (void)setOptionalModulatingMultiplier:(AKParameter *)modulatingMultiplier {
    [self setModulatingMultiplier:modulatingMultiplier];
}

- (void)setModulationIndex:(AKParameter *)modulationIndex {
    _modulationIndex = modulationIndex;
    [self setUpConnections];
}

- (void)setOptionalModulationIndex:(AKParameter *)modulationIndex {
    [self setModulationIndex:modulationIndex];
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
    self.dependencies = @[_baseFrequency, _carrierMultiplier, _modulatingMultiplier, _modulationIndex, _amplitude];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"foscili("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ foscili ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_phase = akp(-1);        
    
    [inputsString appendFormat:@"%@, ", _amplitude];
    
    if ([_baseFrequency class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _baseFrequency];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _baseFrequency];
    }

    [inputsString appendFormat:@"%@, ", _carrierMultiplier];
    
    [inputsString appendFormat:@"%@, ", _modulatingMultiplier];
    
    if ([_modulationIndex class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _modulationIndex];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _modulationIndex];
    }

    [inputsString appendFormat:@"%@, ", _waveform];
    
    [inputsString appendFormat:@"%@", _phase];
    return inputsString;
}

@end
