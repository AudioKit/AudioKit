//
//  AKFunctionTableLooper.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's flooper2:
//  http://www.csounds.com/manual/html/flooper2.html
//

#import "AKFunctionTableLooper.h"
#import "AKManager.h"

@implementation AKFunctionTableLooper
{
    AKFunctionTable * _functionTable;
}

+ (AKConstant *)loopRepeats                      { return akp(0); }
+ (AKConstant *)loopPlaysBackwards               { return akp(1); }
+ (AKConstant *)loopPlaysForwardAndThenBackwards { return akp(2); }

- (instancetype)initWithFunctionTable:(AKFunctionTable *)functionTable
                            startTime:(AKParameter *)startTime
                              endTime:(AKParameter *)endTime
                   transpositionRatio:(AKParameter *)transpositionRatio
                            amplitude:(AKParameter *)amplitude
                    crossfadeDuration:(AKParameter *)crossfadeDuration
                             loopMode:(AKConstant *)loopMode
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _functionTable = functionTable;
        _startTime = startTime;
        _endTime = endTime;
        _transpositionRatio = transpositionRatio;
        _amplitude = amplitude;
        _crossfadeDuration = crossfadeDuration;
        _loopMode = loopMode;
    }
    return self;
}

- (instancetype)initWithFunctionTable:(AKFunctionTable *)functionTable
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _functionTable = functionTable;
        // Default Values
        _startTime = akp(0);
        _endTime = akp(0);
        _transpositionRatio = akp(1);
        _amplitude = akp(1);
        _crossfadeDuration = akp(0);
        _loopMode = [AKFunctionTableLooper loopRepeats];
    }
    return self;
}

+ (instancetype)looperWithFunctionTable:(AKFunctionTable *)functionTable
{
    return [[AKFunctionTableLooper alloc] initWithFunctionTable:functionTable];
}

- (void)setOptionalStartTime:(AKParameter *)startTime {
    _startTime = startTime;
}
- (void)setOptionalEndTime:(AKParameter *)endTime {
    _endTime = endTime;
}
- (void)setOptionalTranspositionRatio:(AKParameter *)transpositionRatio {
    _transpositionRatio = transpositionRatio;
}
- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
}
- (void)setOptionalCrossfadeDuration:(AKParameter *)crossfadeDuration {
    _crossfadeDuration = crossfadeDuration;
}
- (void)setOptionalLoopMode:(AKConstant *)loopMode {
    _loopMode = loopMode;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_crossfadeEnvelopeShapeTable = akp(0);        
    AKConstant *_initialStartTime = akp(0);        
    AKConstant *_skipInitialization = akp(0);        
    [csdString appendFormat:@"%@ flooper2 ", self];

    if ([_amplitude class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _amplitude];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _amplitude];
    }

    if ([_transpositionRatio class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _transpositionRatio];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _transpositionRatio];
    }

    if ([_startTime class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _startTime];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _startTime];
    }

    if ([_endTime class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _endTime];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _endTime];
    }

    if ([_crossfadeDuration class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _crossfadeDuration];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _crossfadeDuration];
    }

    [csdString appendFormat:@"%@, ", _functionTable];
    
    [csdString appendFormat:@"%@, ", _initialStartTime];
    
    [csdString appendFormat:@"%@, ", _loopMode];
    
    [csdString appendFormat:@"%@, ", _crossfadeEnvelopeShapeTable];
    
    [csdString appendFormat:@"%@", _skipInitialization];
    return csdString;
}

@end
