//
//  AKVibrato.m
//  AudioKit
//
//  Auto-generated on 3/2/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's vibrato:
//  http://www.csounds.com/manual/html/vibrato.html
//

#import "AKVibrato.h"
#import "AKManager.h"

@implementation AKVibrato

- (instancetype)initWithShape:(AKTable *)shape
             averageFrequency:(AKParameter *)averageFrequency
          frequencyRandomness:(AKParameter *)frequencyRandomness
   minimumFrequencyRandomness:(AKParameter *)minimumFrequencyRandomness
   maximumFrequencyRandomness:(AKParameter *)maximumFrequencyRandomness
             averageAmplitude:(AKParameter *)averageAmplitude
           amplitudeDeviation:(AKParameter *)amplitudeDeviation
   minimumAmplitudeRandomness:(AKParameter *)minimumAmplitudeRandomness
   maximumAmplitudeRandomness:(AKParameter *)maximumAmplitudeRandomness
                        phase:(AKConstant *)phase
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _shape = shape;
        _averageFrequency = averageFrequency;
        _frequencyRandomness = frequencyRandomness;
        _minimumFrequencyRandomness = minimumFrequencyRandomness;
        _maximumFrequencyRandomness = maximumFrequencyRandomness;
        _averageAmplitude = averageAmplitude;
        _amplitudeDeviation = amplitudeDeviation;
        _minimumAmplitudeRandomness = minimumAmplitudeRandomness;
        _maximumAmplitudeRandomness = maximumAmplitudeRandomness;
        _phase = phase;
        [self setUpConnections];
}
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _shape = [AKTable standardSineWave];
    
        _averageFrequency = akp(2);
        _frequencyRandomness = akp(0);
        _minimumFrequencyRandomness = akp(0);
        _maximumFrequencyRandomness = akp(60);
        _averageAmplitude = akp(1);
        _amplitudeDeviation = akp(0);
        _minimumAmplitudeRandomness = akp(0);
        _maximumAmplitudeRandomness = akp(0);
        _phase = akp(0);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)vibrato
{
    return [[AKVibrato alloc] init];
}

- (void)setShape:(AKTable *)shape {
    _shape = shape;
    [self setUpConnections];
}

- (void)setOptionalShape:(AKTable *)shape {
    [self setShape:shape];
}

- (void)setAverageFrequency:(AKParameter *)averageFrequency {
    _averageFrequency = averageFrequency;
    [self setUpConnections];
}

- (void)setOptionalAverageFrequency:(AKParameter *)averageFrequency {
    [self setAverageFrequency:averageFrequency];
}

- (void)setFrequencyRandomness:(AKParameter *)frequencyRandomness {
    _frequencyRandomness = frequencyRandomness;
    [self setUpConnections];
}

- (void)setOptionalFrequencyRandomness:(AKParameter *)frequencyRandomness {
    [self setFrequencyRandomness:frequencyRandomness];
}

- (void)setMinimumFrequencyRandomness:(AKParameter *)minimumFrequencyRandomness {
    _minimumFrequencyRandomness = minimumFrequencyRandomness;
    [self setUpConnections];
}

- (void)setOptionalMinimumFrequencyRandomness:(AKParameter *)minimumFrequencyRandomness {
    [self setMinimumFrequencyRandomness:minimumFrequencyRandomness];
}

- (void)setMaximumFrequencyRandomness:(AKParameter *)maximumFrequencyRandomness {
    _maximumFrequencyRandomness = maximumFrequencyRandomness;
    [self setUpConnections];
}

- (void)setOptionalMaximumFrequencyRandomness:(AKParameter *)maximumFrequencyRandomness {
    [self setMaximumFrequencyRandomness:maximumFrequencyRandomness];
}

- (void)setAverageAmplitude:(AKParameter *)averageAmplitude {
    _averageAmplitude = averageAmplitude;
    [self setUpConnections];
}

- (void)setOptionalAverageAmplitude:(AKParameter *)averageAmplitude {
    [self setAverageAmplitude:averageAmplitude];
}

- (void)setAmplitudeDeviation:(AKParameter *)amplitudeDeviation {
    _amplitudeDeviation = amplitudeDeviation;
    [self setUpConnections];
}

- (void)setOptionalAmplitudeDeviation:(AKParameter *)amplitudeDeviation {
    [self setAmplitudeDeviation:amplitudeDeviation];
}

- (void)setMinimumAmplitudeRandomness:(AKParameter *)minimumAmplitudeRandomness {
    _minimumAmplitudeRandomness = minimumAmplitudeRandomness;
    [self setUpConnections];
}

- (void)setOptionalMinimumAmplitudeRandomness:(AKParameter *)minimumAmplitudeRandomness {
    [self setMinimumAmplitudeRandomness:minimumAmplitudeRandomness];
}

- (void)setMaximumAmplitudeRandomness:(AKParameter *)maximumAmplitudeRandomness {
    _maximumAmplitudeRandomness = maximumAmplitudeRandomness;
    [self setUpConnections];
}

- (void)setOptionalMaximumAmplitudeRandomness:(AKParameter *)maximumAmplitudeRandomness {
    [self setMaximumAmplitudeRandomness:maximumAmplitudeRandomness];
}

- (void)setPhase:(AKConstant *)phase {
    _phase = phase;
    [self setUpConnections];
}

- (void)setOptionalPhase:(AKConstant *)phase {
    [self setPhase:phase];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_averageFrequency, _frequencyRandomness, _minimumFrequencyRandomness, _maximumFrequencyRandomness, _averageAmplitude, _amplitudeDeviation, _minimumAmplitudeRandomness, _maximumAmplitudeRandomness, _phase];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"vibrato("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ vibrato ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    
    if ([_averageAmplitude class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _averageAmplitude];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _averageAmplitude];
    }

    if ([_averageFrequency class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _averageFrequency];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _averageFrequency];
    }

    if ([_amplitudeDeviation class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _amplitudeDeviation];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _amplitudeDeviation];
    }

    if ([_frequencyRandomness class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _frequencyRandomness];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _frequencyRandomness];
    }

    if ([_minimumAmplitudeRandomness class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _minimumAmplitudeRandomness];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _minimumAmplitudeRandomness];
    }

    if ([_maximumAmplitudeRandomness class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _maximumAmplitudeRandomness];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _maximumAmplitudeRandomness];
    }

    if ([_minimumFrequencyRandomness class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _minimumFrequencyRandomness];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _minimumFrequencyRandomness];
    }

    if ([_maximumFrequencyRandomness class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _maximumFrequencyRandomness];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _maximumFrequencyRandomness];
    }

    [inputsString appendFormat:@"%@, ", _shape];
    
    [inputsString appendFormat:@"%@", _phase];
    return inputsString;
}

@end
