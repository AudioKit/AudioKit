//
//  AKBowedString.m
//  AudioKit
//
//  Auto-generated on 3/2/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's wgbow:
//  http://www.csounds.com/manual/html/wgbow.html
//

#import "AKBowedString.h"
#import "AKManager.h"

@implementation AKBowedString

- (instancetype)initWithFrequency:(AKParameter *)frequency
                        amplitude:(AKParameter *)amplitude
                         pressure:(AKParameter *)pressure
                         position:(AKParameter *)position
                     vibratoShape:(AKTable *)vibratoShape
                 vibratoFrequency:(AKParameter *)vibratoFrequency
                 vibratoAmplitude:(AKParameter *)vibratoAmplitude
                 minimumFrequency:(AKConstant *)minimumFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _frequency = frequency;
        _amplitude = amplitude;
        _pressure = pressure;
        _position = position;
        _vibratoShape = vibratoShape;
        _vibratoFrequency = vibratoFrequency;
        _vibratoAmplitude = vibratoAmplitude;
        _minimumFrequency = minimumFrequency;
        [self setUpConnections];
}
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(110);
        _amplitude = akp(0.5);
        _pressure = akp(3);
        _position = akp(0.127236);
        _vibratoShape = [AKTable standardSineWave];
    
        _vibratoFrequency = akp(0);
        _vibratoAmplitude = akp(0);
        _minimumFrequency = akp(0);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)bowedString
{
    return [[AKBowedString alloc] init];
}

+ (instancetype)presetDefaultBowedString
{
    return [[AKBowedString alloc] init];
}

- (instancetype)initWithPresetWhistlingBowedString
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(770);
        _amplitude = akp(0.5);
        _pressure = akp(10);
        _position = akp(0.127236);
        _vibratoShape = [AKTable standardSineWave];
        
        _vibratoFrequency = akp(0);
        _vibratoAmplitude = akp(0);
        _minimumFrequency = akp(0);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetWhistlingBowedString
{
    return [[AKBowedString alloc] initWithPresetWhistlingBowedString];
}

- (instancetype)initWithPresetTrainWhislteBowedString
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(500);
        _amplitude = akp(0.5);
        _pressure = akp(1);
        _position = akp(0.127236);
        _vibratoShape = [AKTable standardSineWave];
        
        _vibratoFrequency = akp(0);
        _vibratoAmplitude = akp(0);
        _minimumFrequency = akp(0);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetTrainWhislteBowedString
{
    return [[AKBowedString alloc] initWithPresetTrainWhislteBowedString];
}

- (instancetype)initWithPresetFogHornBowedString
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(770);
        _amplitude = akp(0.5);
        _pressure = akp(0);
        _position = akp(10);
        _vibratoShape = [AKTable standardSineWave];
        
        _vibratoFrequency = akp(0);
        _vibratoAmplitude = akp(0);
        _minimumFrequency = akp(0);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetFogHornBowedString
{
    return [[AKBowedString alloc] initWithPresetFogHornBowedString];
}

- (instancetype)initWithPresetCelloBowedString
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(400);
        _amplitude = akp(0.5);
        _pressure = akp(1);
        _position = akp(5);
        _vibratoShape = [AKTable standardSineWave];
        
        _vibratoFrequency = akp(0);
        _vibratoAmplitude = akp(0);
        _minimumFrequency = akp(0);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetCelloBowedString
{
    return [[AKBowedString alloc] initWithPresetCelloBowedString];
}

- (instancetype)initWithPresetFeedbackBowedString
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(200);
        _amplitude = akp(0.5);
        _pressure = akp(1);
        _position = akp(3);
        _vibratoShape = [AKTable standardSineWave];
        
        _vibratoFrequency = akp(0);
        _vibratoAmplitude = akp(0);
        _minimumFrequency = akp(0);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetFeedbackBowedString
{
    return [[AKBowedString alloc] initWithPresetFeedbackBowedString];
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

- (void)setPressure:(AKParameter *)pressure {
    _pressure = pressure;
    [self setUpConnections];
}

- (void)setOptionalPressure:(AKParameter *)pressure {
    [self setPressure:pressure];
}

- (void)setPosition:(AKParameter *)position {
    _position = position;
    [self setUpConnections];
}

- (void)setOptionalPosition:(AKParameter *)position {
    [self setPosition:position];
}

- (void)setVibratoShape:(AKTable *)vibratoShape {
    _vibratoShape = vibratoShape;
    [self setUpConnections];
}

- (void)setOptionalVibratoShape:(AKTable *)vibratoShape {
    [self setVibratoShape:vibratoShape];
}

- (void)setVibratoFrequency:(AKParameter *)vibratoFrequency {
    _vibratoFrequency = vibratoFrequency;
    [self setUpConnections];
}

- (void)setOptionalVibratoFrequency:(AKParameter *)vibratoFrequency {
    [self setVibratoFrequency:vibratoFrequency];
}

- (void)setVibratoAmplitude:(AKParameter *)vibratoAmplitude {
    _vibratoAmplitude = vibratoAmplitude;
    [self setUpConnections];
}

- (void)setOptionalVibratoAmplitude:(AKParameter *)vibratoAmplitude {
    [self setVibratoAmplitude:vibratoAmplitude];
}

- (void)setMinimumFrequency:(AKConstant *)minimumFrequency {
    _minimumFrequency = minimumFrequency;
    [self setUpConnections];
}

- (void)setOptionalMinimumFrequency:(AKConstant *)minimumFrequency {
    [self setMinimumFrequency:minimumFrequency];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_frequency, _amplitude, _pressure, _position, _vibratoFrequency, _vibratoAmplitude, _minimumFrequency];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"wgbow("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ wgbow ", self];
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

    if ([_pressure class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _pressure];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _pressure];
    }

    if ([_position class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _position];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _position];
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
    
    [inputsString appendFormat:@"%@", _minimumFrequency];
    return inputsString;
}

@end
