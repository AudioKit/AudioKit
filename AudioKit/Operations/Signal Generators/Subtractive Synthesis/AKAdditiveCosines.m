//
//  AKAdditiveCosines.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's gbuzz:
//  http://www.csounds.com/manual/html/gbuzz.html
//

#import "AKAdditiveCosines.h"
#import "AKManager.h"

@implementation AKAdditiveCosines
{
    AKFunctionTable * _cosineTable;
}

- (instancetype)initWithCosineTable:(AKFunctionTable *)cosineTable
                     harmonicsCount:(AKParameter *)harmonicsCount
                 firstHarmonicIndex:(AKParameter *)firstHarmonicIndex
                  partialMultiplier:(AKParameter *)partialMultiplier
               fundamentalFrequency:(AKParameter *)fundamentalFrequency
                          amplitude:(AKParameter *)amplitude
                              phase:(AKConstant *)phase
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _cosineTable = cosineTable;
        _harmonicsCount = harmonicsCount;
        _firstHarmonicIndex = firstHarmonicIndex;
        _partialMultiplier = partialMultiplier;
        _fundamentalFrequency = fundamentalFrequency;
        _amplitude = amplitude;
        _phase = phase;
    }
    return self;
}

- (instancetype)initWithCosineTable:(AKFunctionTable *)cosineTable
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _cosineTable = cosineTable;
        // Default Values
        _harmonicsCount = akp(10);
        _firstHarmonicIndex = akp(1);
        _partialMultiplier = akp(1);
        _fundamentalFrequency = akp(220);
        _amplitude = akp(1);
        _phase = akp(0);
    }
    return self;
}

+ (instancetype)cosinesWithCosineTable:(AKFunctionTable *)cosineTable
{
    return [[AKAdditiveCosines alloc] initWithCosineTable:cosineTable];
}

- (void)setOptionalHarmonicsCount:(AKParameter *)harmonicsCount {
    _harmonicsCount = harmonicsCount;
}
- (void)setOptionalFirstHarmonicIndex:(AKParameter *)firstHarmonicIndex {
    _firstHarmonicIndex = firstHarmonicIndex;
}
- (void)setOptionalPartialMultiplier:(AKParameter *)partialMultiplier {
    _partialMultiplier = partialMultiplier;
}
- (void)setOptionalFundamentalFrequency:(AKParameter *)fundamentalFrequency {
    _fundamentalFrequency = fundamentalFrequency;
}
- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
}
- (void)setOptionalPhase:(AKConstant *)phase {
    _phase = phase;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ gbuzz ", self];

    [csdString appendFormat:@"%@, ", _amplitude];
    
    [csdString appendFormat:@"%@, ", _fundamentalFrequency];
    
    if ([_harmonicsCount class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _harmonicsCount];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _harmonicsCount];
    }

    if ([_firstHarmonicIndex class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _firstHarmonicIndex];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _firstHarmonicIndex];
    }

    if ([_partialMultiplier class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _partialMultiplier];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _partialMultiplier];
    }

    [csdString appendFormat:@"%@, ", _cosineTable];
    
    [csdString appendFormat:@"%@", _phase];
    return csdString;
}

@end
