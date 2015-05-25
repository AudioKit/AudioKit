//
//  AKFlute.m
//  AudioKit
//
//  Auto-generated on 5/25/15.
//  Customized by Aurelius Prochazka to skip initialization on held notes with tival()
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's wgflute:
//  http://www.csounds.com/manual/html/wgflute.html
//

#import "AKFlute.h"
#import "AKManager.h"

@implementation AKFlute

- (instancetype)initWithFrequency:(AKParameter *)frequency
                       attackTime:(AKConstant *)attackTime
                      releaseTime:(AKConstant *)releaseTime
                   airJetPressure:(AKParameter *)airJetPressure
                 airJetReflection:(AKConstant *)airJetReflection
            reflectionCoefficient:(AKConstant *)reflectionCoefficient
                   noiseAmplitude:(AKParameter *)noiseAmplitude
                        amplitude:(AKParameter *)amplitude
                     vibratoShape:(AKTable *)vibratoShape
                 vibratoAmplitude:(AKParameter *)vibratoAmplitude
                 vibratoFrequency:(AKParameter *)vibratoFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _frequency = frequency;
        _attackTime = attackTime;
        _releaseTime = releaseTime;
        _airJetPressure = airJetPressure;
        _airJetReflection = airJetReflection;
        _reflectionCoefficient = reflectionCoefficient;
        _noiseAmplitude = noiseAmplitude;
        _amplitude = amplitude;
        _vibratoShape = vibratoShape;
        _vibratoAmplitude = vibratoAmplitude;
        _vibratoFrequency = vibratoFrequency;
        [self setUpConnections];
}
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(440);
        _attackTime = akp(0.1);
        _releaseTime = akp(0.1);
        _airJetPressure = akp(0.2);
        _airJetReflection = akp(0.5);
        _reflectionCoefficient = akp(0.5);
        _noiseAmplitude = akp(0.15);
        _amplitude = akp(0.5);
        _vibratoShape = [AKTable standardSineWave];
    
        _vibratoAmplitude = akp(0);
        _vibratoFrequency = akp(0);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)flute
{
    return [[AKFlute alloc] init];
}

+ (instancetype)presetDefaultFlute
{
    return [[AKFlute alloc] init];
}

- (instancetype)initWithPresetMicFeedbackFlute
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(900);
        _attackTime = akp(0.2);
        _releaseTime = akp(1);
        _airJetPressure = akp(2);
        _airJetReflection = akp(0.5);
        _reflectionCoefficient = akp(0.8);
        _noiseAmplitude = akp(0.1);
        _amplitude = akp(0.5);
        _vibratoShape = [AKTable standardSineWave];
        
        _vibratoAmplitude = akp(0);
        _vibratoFrequency = akp(0);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetMicFeedbackFlute
{
    return [[AKFlute alloc] initWithPresetMicFeedbackFlute];
}

- (instancetype)initWithPresetShipsHornFlute
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(220);
        _attackTime = akp(0.1);
        _releaseTime = akp(0.3);
        _airJetPressure = akp(2);
        _airJetReflection = akp(0.5);
        _reflectionCoefficient = akp(0.4);
        _noiseAmplitude = akp(0.15);
        _amplitude = akp(0.5);
        _vibratoShape = [AKTable standardSineWave];
        
        _vibratoAmplitude = akp(0);
        _vibratoFrequency = akp(0);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetShipsHornFlute
{
    return [[AKFlute alloc] initWithPresetShipsHornFlute];
}

- (instancetype)initWithPresetSciFiNoiseFlute
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(50);
        _attackTime = akp(0.1);
        _releaseTime = akp(0.9);
        _airJetPressure = akp(0.2);
        _airJetReflection = akp(0.9);
        _reflectionCoefficient = akp(0.5);
        _noiseAmplitude = akp(0.12);
        _amplitude = akp(0.5);
        _vibratoShape = [AKTable standardSineWave];
        
        _vibratoAmplitude = akp(0);
        _vibratoFrequency = akp(0);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetSciFiNoiseFlute
{
    return [[AKFlute alloc] initWithPresetSciFiNoiseFlute];
}

- (instancetype)initWithPresetScreamingFlute
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(10);
        _attackTime = akp(0.1);
        _releaseTime = akp(0);
        _airJetPressure = akp(0.2);
        _airJetReflection = akp(0.9);
        _reflectionCoefficient = akp(0.6);
        _noiseAmplitude = akp(1);
        _amplitude = akp(0.5);
        _vibratoShape = [AKTable standardSineWave];
        
        _vibratoAmplitude = akp(0);
        _vibratoFrequency = akp(0);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetScreamingFlute
{
    return [[AKFlute alloc] initWithPresetScreamingFlute];
}

- (void)setFrequency:(AKParameter *)frequency {
    _frequency = frequency;
    [self setUpConnections];
}

- (void)setOptionalFrequency:(AKParameter *)frequency {
    [self setFrequency:frequency];
}

- (void)setAttackTime:(AKConstant *)attackTime {
    _attackTime = attackTime;
    [self setUpConnections];
}

- (void)setOptionalAttackTime:(AKConstant *)attackTime {
    [self setAttackTime:attackTime];
}

- (void)setReleaseTime:(AKConstant *)releaseTime {
    _releaseTime = releaseTime;
    [self setUpConnections];
}

- (void)setOptionalReleaseTime:(AKConstant *)releaseTime {
    [self setReleaseTime:releaseTime];
}

- (void)setAirJetPressure:(AKParameter *)airJetPressure {
    _airJetPressure = airJetPressure;
    [self setUpConnections];
}

- (void)setOptionalAirJetPressure:(AKParameter *)airJetPressure {
    [self setAirJetPressure:airJetPressure];
}

- (void)setAirJetReflection:(AKConstant *)airJetReflection {
    _airJetReflection = airJetReflection;
    [self setUpConnections];
}

- (void)setOptionalAirJetReflection:(AKConstant *)airJetReflection {
    [self setAirJetReflection:airJetReflection];
}

- (void)setReflectionCoefficient:(AKConstant *)reflectionCoefficient {
    _reflectionCoefficient = reflectionCoefficient;
    [self setUpConnections];
}

- (void)setOptionalReflectionCoefficient:(AKConstant *)reflectionCoefficient {
    [self setReflectionCoefficient:reflectionCoefficient];
}

- (void)setNoiseAmplitude:(AKParameter *)noiseAmplitude {
    _noiseAmplitude = noiseAmplitude;
    [self setUpConnections];
}

- (void)setOptionalNoiseAmplitude:(AKParameter *)noiseAmplitude {
    [self setNoiseAmplitude:noiseAmplitude];
}

- (void)setAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
    [self setUpConnections];
}

- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    [self setAmplitude:amplitude];
}

- (void)setVibratoShape:(AKTable *)vibratoShape {
    _vibratoShape = vibratoShape;
    [self setUpConnections];
}

- (void)setOptionalVibratoShape:(AKTable *)vibratoShape {
    [self setVibratoShape:vibratoShape];
}

- (void)setVibratoAmplitude:(AKParameter *)vibratoAmplitude {
    _vibratoAmplitude = vibratoAmplitude;
    [self setUpConnections];
}

- (void)setOptionalVibratoAmplitude:(AKParameter *)vibratoAmplitude {
    [self setVibratoAmplitude:vibratoAmplitude];
}

- (void)setVibratoFrequency:(AKParameter *)vibratoFrequency {
    _vibratoFrequency = vibratoFrequency;
    [self setUpConnections];
}

- (void)setOptionalVibratoFrequency:(AKParameter *)vibratoFrequency {
    [self setVibratoFrequency:vibratoFrequency];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_frequency, _attackTime, _releaseTime, _airJetPressure, _airJetReflection, _reflectionCoefficient, _noiseAmplitude, _amplitude, _vibratoAmplitude, _vibratoFrequency];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"wgflute("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ wgflute ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_initializationParameter = akp(0);        
    
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

    if ([_airJetPressure class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _airJetPressure];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _airJetPressure];
    }

    [inputsString appendFormat:@"%@, ", _attackTime];
    
    [inputsString appendFormat:@"%@, ", _releaseTime];
    
    if ([_noiseAmplitude class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _noiseAmplitude];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _noiseAmplitude];
    }

    if ([_vibratoFrequency class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _vibratoFrequency];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _vibratoFrequency];
    }

    if ([_vibratoAmplitude class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _vibratoAmplitude];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _vibratoAmplitude];
    }

    [inputsString appendFormat:@"%@, ", _vibratoShape];
    
    [inputsString appendFormat:@"%@-tival(), ", _initializationParameter];
    
    [inputsString appendFormat:@"%@, ", _airJetReflection];
    
    [inputsString appendFormat:@"%@", _reflectionCoefficient];
    return inputsString;
}

@end
