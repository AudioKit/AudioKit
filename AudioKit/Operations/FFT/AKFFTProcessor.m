//
//  AKFFTProcessor.m
//  AudioKit
//
//  Auto-generated on 2/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's pvstanal:
//  http://www.csounds.com/manual/html/pvstanal.html
//

#import "AKFFTProcessor.h"
#import "AKManager.h"

@implementation AKFFTProcessor
{
    AKParameter * _functionTable;
}

- (instancetype)initWithFunctionTable:(AKParameter *)functionTable
                       frequencyRatio:(AKParameter *)frequencyRatio
                            timeRatio:(AKParameter *)timeRatio
                            amplitude:(AKParameter *)amplitude
                  functionTableOffset:(AKConstant *)functionTableOffset
                            sizeOfFFT:(AKConstant *)sizeOfFFT
                              hopSize:(AKConstant *)hopSize
                             dbthresh:(AKConstant *)dbthresh
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _functionTable = functionTable;
        _frequencyRatio = frequencyRatio;
        _timeRatio = timeRatio;
        _amplitude = amplitude;
        _functionTableOffset = functionTableOffset;
        _sizeOfFFT = sizeOfFFT;
        _hopSize = hopSize;
        _dbthresh = dbthresh;
        [self setUpConnections];
}
    return self;
}

- (instancetype)initWithFunctionTable:(AKParameter *)functionTable
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _functionTable = functionTable;
        // Default Values
        _frequencyRatio = akp(1);
        _timeRatio = akp(1);
        _amplitude = akp(1);
        _functionTableOffset = akp(0);
        _sizeOfFFT = akp(2048);
        _hopSize = akp(512);
        _dbthresh = akp(1);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)WithFunctionTable:(AKParameter *)functionTable
{
    return [[AKFFTProcessor alloc] initWithFunctionTable:functionTable];
}

- (void)setFrequencyRatio:(AKParameter *)frequencyRatio {
    _frequencyRatio = frequencyRatio;
    [self setUpConnections];
}

- (void)setOptionalFrequencyRatio:(AKParameter *)frequencyRatio {
    [self setFrequencyRatio:frequencyRatio];
}

- (void)setTimeRatio:(AKParameter *)timeRatio {
    _timeRatio = timeRatio;
    [self setUpConnections];
}

- (void)setOptionalTimeRatio:(AKParameter *)timeRatio {
    [self setTimeRatio:timeRatio];
}

- (void)setAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
    [self setUpConnections];
}

- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    [self setAmplitude:amplitude];
}

- (void)setFunctionTableOffset:(AKConstant *)functionTableOffset {
    _functionTableOffset = functionTableOffset;
    [self setUpConnections];
}

- (void)setOptionalFunctionTableOffset:(AKConstant *)functionTableOffset {
    [self setFunctionTableOffset:functionTableOffset];
}

- (void)setSizeOfFFT:(AKConstant *)sizeOfFFT {
    _sizeOfFFT = sizeOfFFT;
    [self setUpConnections];
}

- (void)setOptionalSizeOfFFT:(AKConstant *)sizeOfFFT {
    [self setSizeOfFFT:sizeOfFFT];
}

- (void)setHopSize:(AKConstant *)hopSize {
    _hopSize = hopSize;
    [self setUpConnections];
}

- (void)setOptionalHopSize:(AKConstant *)hopSize {
    [self setHopSize:hopSize];
}

- (void)setDbthresh:(AKConstant *)dbthresh {
    _dbthresh = dbthresh;
    [self setUpConnections];
}

- (void)setOptionalDbthresh:(AKConstant *)dbthresh {
    [self setDbthresh:dbthresh];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_functionTable, _frequencyRatio, _timeRatio, _amplitude, _functionTableOffset, _sizeOfFFT, _hopSize, _dbthresh];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"pvstanal("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ pvstanal ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_wrap = akp(1);        
    
    if ([_timeRatio class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _timeRatio];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _timeRatio];
    }

    if ([_amplitude class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _amplitude];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _amplitude];
    }

    if ([_frequencyRatio class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _frequencyRatio];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _frequencyRatio];
    }

    if ([_functionTable class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _functionTable];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _functionTable];
    }

    if ([_wrap class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _wrap];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _wrap];
    }

    [inputsString appendFormat:@"%@, ", _functionTableOffset];
    
    [inputsString appendFormat:@"%@, ", _sizeOfFFT];
    
    [inputsString appendFormat:@"%@, ", _hopSize];
    
    [inputsString appendFormat:@"%@", _dbthresh];
    return inputsString;
}

@end
