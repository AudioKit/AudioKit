//
//  AKGranularSynthesisTexture.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Customized by Aurelius Prochazka on 1/12/15, reversing random offset logic.

//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's grain:
//  http://www.csounds.com/manual/html/grain.html
//

#import "AKGranularSynthesisTexture.h"
#import "AKManager.h"

@implementation AKGranularSynthesisTexture
{
    AKTable * _grainTable;
    AKTable * _windowTable;
}

- (instancetype)initWithGrainTable:(AKTable *)grainTable
                       windowTable:(AKTable *)windowTable
              maximumGrainDuration:(AKConstant *)maximumGrainDuration
              averageGrainDuration:(AKParameter *)averageGrainDuration
         maximumFrequencyDeviation:(AKParameter *)maximumFrequencyDeviation
                    grainFrequency:(AKParameter *)grainFrequency
         maximumAmplitudeDeviation:(AKParameter *)maximumAmplitudeDeviation
                    grainAmplitude:(AKParameter *)grainAmplitude
                      grainDensity:(AKParameter *)grainDensity
              useRandomGrainOffset:(BOOL)useRandomGrainOffset
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _grainTable = grainTable;
        _windowTable = windowTable;
        _maximumGrainDuration = maximumGrainDuration;
        _averageGrainDuration = averageGrainDuration;
        _maximumFrequencyDeviation = maximumFrequencyDeviation;
        _grainFrequency = grainFrequency;
        _maximumAmplitudeDeviation = maximumAmplitudeDeviation;
        _grainAmplitude = grainAmplitude;
        _grainDensity = grainDensity;
        _useRandomGrainOffset = useRandomGrainOffset;
        [self setUpConnections];
    }
    return self;
}

- (instancetype)initWithGrainTable:(AKTable *)grainTable
                       windowTable:(AKTable *)windowTable
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _grainTable = grainTable;
        _windowTable = windowTable;
        // Default Values
        _maximumGrainDuration = akp(0.5);
        _averageGrainDuration = akp(0.4);
        _maximumFrequencyDeviation = akp(0.5);
        _grainFrequency = akp(0.8);
        _maximumAmplitudeDeviation = akp(0.1);
        _grainAmplitude = akp(0.01);
        _grainDensity = akp(500);
        _useRandomGrainOffset = true;
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)textureWithGrainTable:(AKTable *)grainTable
                          windowTable:(AKTable *)windowTable
{
    return [[AKGranularSynthesisTexture alloc] initWithGrainTable:grainTable
                                                      windowTable:windowTable];
}

- (void)setMaximumGrainDuration:(AKConstant *)maximumGrainDuration {
    _maximumGrainDuration = maximumGrainDuration;
    [self setUpConnections];
}

- (void)setOptionalMaximumGrainDuration:(AKConstant *)maximumGrainDuration {
    [self setMaximumGrainDuration:maximumGrainDuration];
}

- (void)setAverageGrainDuration:(AKParameter *)averageGrainDuration {
    _averageGrainDuration = averageGrainDuration;
    [self setUpConnections];
}

- (void)setOptionalAverageGrainDuration:(AKParameter *)averageGrainDuration {
    [self setAverageGrainDuration:averageGrainDuration];
}

- (void)setMaximumFrequencyDeviation:(AKParameter *)maximumFrequencyDeviation {
    _maximumFrequencyDeviation = maximumFrequencyDeviation;
    [self setUpConnections];
}

- (void)setOptionalMaximumFrequencyDeviation:(AKParameter *)maximumFrequencyDeviation {
    [self setMaximumFrequencyDeviation:maximumFrequencyDeviation];
}

- (void)setGrainFrequency:(AKParameter *)grainFrequency {
    _grainFrequency = grainFrequency;
    [self setUpConnections];
}

- (void)setOptionalGrainFrequency:(AKParameter *)grainFrequency {
    [self setGrainFrequency:grainFrequency];
}

- (void)setMaximumAmplitudeDeviation:(AKParameter *)maximumAmplitudeDeviation {
    _maximumAmplitudeDeviation = maximumAmplitudeDeviation;
    [self setUpConnections];
}

- (void)setOptionalMaximumAmplitudeDeviation:(AKParameter *)maximumAmplitudeDeviation {
    [self setMaximumAmplitudeDeviation:maximumAmplitudeDeviation];
}

- (void)setGrainAmplitude:(AKParameter *)grainAmplitude {
    _grainAmplitude = grainAmplitude;
    [self setUpConnections];
}

- (void)setOptionalGrainAmplitude:(AKParameter *)grainAmplitude {
    [self setGrainAmplitude:grainAmplitude];
}

- (void)setGrainDensity:(AKParameter *)grainDensity {
    _grainDensity = grainDensity;
    [self setUpConnections];
}

- (void)setOptionalGrainDensity:(AKParameter *)grainDensity {
    [self setGrainDensity:grainDensity];
}

- (void)setUseRandomGrainOffset:(BOOL)useRandomGrainOffset {
    _useRandomGrainOffset = useRandomGrainOffset;
    [self setUpConnections];
}

- (void)setOptionalUseRandomGrainOffset:(BOOL)useRandomGrainOffset {
    [self setUseRandomGrainOffset:useRandomGrainOffset];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_maximumGrainDuration, _averageGrainDuration, _maximumFrequencyDeviation, _grainFrequency, _maximumAmplitudeDeviation, _grainAmplitude, _grainDensity];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];
    
    [inlineCSDString appendString:@"grain("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];
    
    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    [csdString appendFormat:@"%@ grain ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];
    
    
    [inputsString appendFormat:@"%@, ", _grainAmplitude];
    
    [inputsString appendFormat:@"%@, ", _grainFrequency];
    
    [inputsString appendFormat:@"%@, ", _grainDensity];
    
    if ([_maximumAmplitudeDeviation class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _maximumAmplitudeDeviation];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _maximumAmplitudeDeviation];
    }
    
    if ([_maximumFrequencyDeviation class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _maximumFrequencyDeviation];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _maximumFrequencyDeviation];
    }
    
    if ([_averageGrainDuration class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _averageGrainDuration];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _averageGrainDuration];
    }
    
    [inputsString appendFormat:@"%@, ", _grainTable];
    
    [inputsString appendFormat:@"%@, ", _windowTable];
    
    [inputsString appendFormat:@"%@, ", _maximumGrainDuration];
    
    [inputsString appendFormat:@"%@", akpi(!_useRandomGrainOffset)];
    return inputsString;
}

@end
