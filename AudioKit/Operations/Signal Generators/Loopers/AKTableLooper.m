//
//  AKTableLooper.m
//  AudioKit
//
//  Auto-generated on 3/3/15.
//  Customized by Aurelius Prochazka to include types as class methods
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's flooper2:
//  http://www.csounds.com/manual/html/flooper2.html
//

#import "AKTableLooper.h"
#import "AKManager.h"

@implementation AKTableLooper
{
    AKTable * _table;
}

+ (AKConstant *)loopRepeats                      { return akp(0); }
+ (AKConstant *)loopPlaysBackwards               { return akp(1); }
+ (AKConstant *)loopPlaysForwardAndThenBackwards { return akp(2); }

- (instancetype)initWithTable:(AKTable *)table
                    startTime:(AKParameter *)startTime
                      endTime:(AKParameter *)endTime
           transpositionRatio:(AKParameter *)transpositionRatio
                    amplitude:(AKParameter *)amplitude
            crossfadeDuration:(AKParameter *)crossfadeDuration
                     loopMode:(AKConstant *)loopMode
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _table = table;
        _startTime = startTime;
        _endTime = endTime;
        _transpositionRatio = transpositionRatio;
        _amplitude = amplitude;
        _crossfadeDuration = crossfadeDuration;
        _loopMode = loopMode;
        [self setUpConnections];
    }
    return self;
}

- (instancetype)initWithTable:(AKTable *)table
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _table = table;
        // Default Values
        _startTime = akp(0);
        _endTime = akp(0);
        _transpositionRatio = akp(1);
        _amplitude = akp(0.5);
        _crossfadeDuration = akp(0);
        _loopMode = [AKTableLooper loopRepeats];
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)looperWithTable:(AKTable *)table
{
    return [[AKTableLooper alloc] initWithTable:table];
}

- (void)setStartTime:(AKParameter *)startTime {
    _startTime = startTime;
    [self setUpConnections];
}

- (void)setOptionalStartTime:(AKParameter *)startTime {
    [self setStartTime:startTime];
}

- (void)setEndTime:(AKParameter *)endTime {
    _endTime = endTime;
    [self setUpConnections];
}

- (void)setOptionalEndTime:(AKParameter *)endTime {
    [self setEndTime:endTime];
}

- (void)setTranspositionRatio:(AKParameter *)transpositionRatio {
    _transpositionRatio = transpositionRatio;
    [self setUpConnections];
}

- (void)setOptionalTranspositionRatio:(AKParameter *)transpositionRatio {
    [self setTranspositionRatio:transpositionRatio];
}

- (void)setAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
    [self setUpConnections];
}

- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    [self setAmplitude:amplitude];
}

- (void)setCrossfadeDuration:(AKParameter *)crossfadeDuration {
    _crossfadeDuration = crossfadeDuration;
    [self setUpConnections];
}

- (void)setOptionalCrossfadeDuration:(AKParameter *)crossfadeDuration {
    [self setCrossfadeDuration:crossfadeDuration];
}

- (void)setLoopMode:(AKConstant *)loopMode {
    _loopMode = loopMode;
    [self setUpConnections];
}

- (void)setOptionalLoopMode:(AKConstant *)loopMode {
    [self setLoopMode:loopMode];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_startTime, _endTime, _transpositionRatio, _amplitude, _crossfadeDuration, _loopMode];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];
    
    [inlineCSDString appendString:@"flooper2("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];
    
    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    [csdString appendFormat:@"%@ flooper2 ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];
    
    // Constant Values
    AKConstant *_crossfadeEnvelope = akp(0);
    AKConstant *_initialStartTime = akp(0);
    AKConstant *_skipInitialization = akp(0);
    
    if ([_amplitude class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _amplitude];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _amplitude];
    }
    
    if ([_transpositionRatio class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _transpositionRatio];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _transpositionRatio];
    }
    
    if ([_startTime class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _startTime];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _startTime];
    }
    
    if ([_endTime class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _endTime];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _endTime];
    }
    
    if ([_crossfadeDuration class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _crossfadeDuration];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _crossfadeDuration];
    }
    
    [inputsString appendFormat:@"%@, ", _table];
    
    [inputsString appendFormat:@"%@, ", _initialStartTime];
    
    [inputsString appendFormat:@"%@, ", _loopMode];
    
    [inputsString appendFormat:@"%@, ", _crossfadeEnvelope];
    
    [inputsString appendFormat:@"%@", _skipInitialization];
    return inputsString;
}

@end
