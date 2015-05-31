//
//  AKAdditiveCosines.m
//  AudioKit
//
//  Auto-generated on 2/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's gbuzz:
//  http://www.csounds.com/manual/html/gbuzz.html
//

#import "AKAdditiveCosines.h"
#import "AKManager.h"

@implementation AKAdditiveCosines
{
    AKTable *_cosineTable;
}

- (instancetype)initWithCosineTable:(AKTable *)cosineTable
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
        [self setUpConnections];
}
    return self;
}

- (instancetype)initWithCosineTable:(AKTable *)cosineTable
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _cosineTable = cosineTable;
        // Default Values
        _harmonicsCount = akp(10);
        _firstHarmonicIndex = akp(1);
        _partialMultiplier = akp(1);
        _fundamentalFrequency = akp(220);
        _amplitude = akp(0.5);
        _phase = akp(0);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)cosinesWithCosineTable:(AKTable *)cosineTable
{
    return [[AKAdditiveCosines alloc] initWithCosineTable:cosineTable];
}

- (void)setHarmonicsCount:(AKParameter *)harmonicsCount {
    _harmonicsCount = harmonicsCount;
    [self setUpConnections];
}

- (void)setOptionalHarmonicsCount:(AKParameter *)harmonicsCount {
    [self setHarmonicsCount:harmonicsCount];
}

- (void)setFirstHarmonicIndex:(AKParameter *)firstHarmonicIndex {
    _firstHarmonicIndex = firstHarmonicIndex;
    [self setUpConnections];
}

- (void)setOptionalFirstHarmonicIndex:(AKParameter *)firstHarmonicIndex {
    [self setFirstHarmonicIndex:firstHarmonicIndex];
}

- (void)setPartialMultiplier:(AKParameter *)partialMultiplier {
    _partialMultiplier = partialMultiplier;
    [self setUpConnections];
}

- (void)setOptionalPartialMultiplier:(AKParameter *)partialMultiplier {
    [self setPartialMultiplier:partialMultiplier];
}

- (void)setFundamentalFrequency:(AKParameter *)fundamentalFrequency {
    _fundamentalFrequency = fundamentalFrequency;
    [self setUpConnections];
}

- (void)setOptionalFundamentalFrequency:(AKParameter *)fundamentalFrequency {
    [self setFundamentalFrequency:fundamentalFrequency];
}

- (void)setAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
    [self setUpConnections];
}

- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    [self setAmplitude:amplitude];
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
    self.dependencies = @[_cosineTable, _harmonicsCount, _firstHarmonicIndex, _partialMultiplier, _fundamentalFrequency, _amplitude, _phase];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"gbuzz("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ gbuzz ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    
    [inputsString appendFormat:@"%@, ", _amplitude];
    
    [inputsString appendFormat:@"%@, ", _fundamentalFrequency];
    
    if ([_harmonicsCount class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _harmonicsCount];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _harmonicsCount];
    }

    if ([_firstHarmonicIndex class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _firstHarmonicIndex];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _firstHarmonicIndex];
    }

    if ([_partialMultiplier class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _partialMultiplier];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _partialMultiplier];
    }

    [inputsString appendFormat:@"%@, ", _cosineTable];
    
    [inputsString appendFormat:@"%@", _phase];
    return inputsString;
}

@end
