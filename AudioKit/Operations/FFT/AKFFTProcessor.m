//
//  AKFFTProcessor.m
//  AudioKit
//
//  Auto-generated on 1/27/15.
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
    }
    return self;
}

+ (instancetype)WithFunctionTable:(AKParameter *)functionTable
{
    return [[AKFFTProcessor alloc] initWithFunctionTable:functionTable];
}

- (void)setOptionalFrequencyRatio:(AKParameter *)frequencyRatio {
    _frequencyRatio = frequencyRatio;
}
- (void)setOptionalTimeRatio:(AKParameter *)timeRatio {
    _timeRatio = timeRatio;
}
- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
}
- (void)setOptionalFunctionTableOffset:(AKConstant *)functionTableOffset {
    _functionTableOffset = functionTableOffset;
}
- (void)setOptionalSizeOfFFT:(AKConstant *)sizeOfFFT {
    _sizeOfFFT = sizeOfFFT;
}
- (void)setOptionalHopSize:(AKConstant *)hopSize {
    _hopSize = hopSize;
}
- (void)setOptionalDbthresh:(AKConstant *)dbthresh {
    _dbthresh = dbthresh;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_wrap = akp(1);        
    [csdString appendFormat:@"%@ pvstanal ", self];

    if ([_timeRatio class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _timeRatio];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _timeRatio];
    }

    if ([_amplitude class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _amplitude];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _amplitude];
    }

    if ([_frequencyRatio class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _frequencyRatio];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _frequencyRatio];
    }

    if ([_functionTable class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _functionTable];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _functionTable];
    }

    if ([_wrap class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _wrap];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _wrap];
    }

    [csdString appendFormat:@"%@, ", _functionTableOffset];
    
    [csdString appendFormat:@"%@, ", _sizeOfFFT];
    
    [csdString appendFormat:@"%@, ", _hopSize];
    
    [csdString appendFormat:@"%@", _dbthresh];
    return csdString;
}

@end
