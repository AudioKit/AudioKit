//
//  AKAMDFTrackedFrequency.m
//  AudioKit
//
//  Auto-generated on 12/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's pitchamdf:
//  http://www.csounds.com/manual/html/pitchamdf.html
//

#import "AKAMDFTrackedFrequency.h"
#import "AKManager.h"

@implementation AKAMDFTrackedFrequency
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
    estimatedMinimumFrequency:(AKConstant *)estimatedMinimumFrequency
    estimatedMaximumFrequency:(AKConstant *)estimatedMaximumFrequency
    estimatedInitialFrequency:(AKConstant *)estimatedInitialFrequency
             medianFilterSize:(AKConstant *)medianFilterSize
           downsamplingFactor:(AKConstant *)downsamplingFactor
              updateFrequency:(AKConstant *)updateFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _estimatedMinimumFrequency = estimatedMinimumFrequency;
        _estimatedMaximumFrequency = estimatedMaximumFrequency;
        _estimatedInitialFrequency = estimatedInitialFrequency;
        _medianFilterSize = medianFilterSize;
        _downsamplingFactor = downsamplingFactor;
        _updateFrequency = updateFrequency;
        [self setUpConnections];
}
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _estimatedMinimumFrequency = akp(20);
        _estimatedMaximumFrequency = akp(4000);
        _estimatedInitialFrequency = akp(0);
        _medianFilterSize = akp(1);
        _downsamplingFactor = akp(1);
        _updateFrequency = akp(0);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)WithInput:(AKParameter *)input
{
    return [[AKAMDFTrackedFrequency alloc] initWithInput:input];
}

- (void)setEstimatedMinimumFrequency:(AKConstant *)estimatedMinimumFrequency {
    _estimatedMinimumFrequency = estimatedMinimumFrequency;
    [self setUpConnections];
}

- (void)setOptionalEstimatedMinimumFrequency:(AKConstant *)estimatedMinimumFrequency {
    [self setEstimatedMinimumFrequency:estimatedMinimumFrequency];
}

- (void)setEstimatedMaximumFrequency:(AKConstant *)estimatedMaximumFrequency {
    _estimatedMaximumFrequency = estimatedMaximumFrequency;
    [self setUpConnections];
}

- (void)setOptionalEstimatedMaximumFrequency:(AKConstant *)estimatedMaximumFrequency {
    [self setEstimatedMaximumFrequency:estimatedMaximumFrequency];
}

- (void)setEstimatedInitialFrequency:(AKConstant *)estimatedInitialFrequency {
    _estimatedInitialFrequency = estimatedInitialFrequency;
    [self setUpConnections];
}

- (void)setOptionalEstimatedInitialFrequency:(AKConstant *)estimatedInitialFrequency {
    [self setEstimatedInitialFrequency:estimatedInitialFrequency];
}

- (void)setMedianFilterSize:(AKConstant *)medianFilterSize {
    _medianFilterSize = medianFilterSize;
    [self setUpConnections];
}

- (void)setOptionalMedianFilterSize:(AKConstant *)medianFilterSize {
    [self setMedianFilterSize:medianFilterSize];
}

- (void)setDownsamplingFactor:(AKConstant *)downsamplingFactor {
    _downsamplingFactor = downsamplingFactor;
    [self setUpConnections];
}

- (void)setOptionalDownsamplingFactor:(AKConstant *)downsamplingFactor {
    [self setDownsamplingFactor:downsamplingFactor];
}

- (void)setUpdateFrequency:(AKConstant *)updateFrequency {
    _updateFrequency = updateFrequency;
    [self setUpConnections];
}

- (void)setOptionalUpdateFrequency:(AKConstant *)updateFrequency {
    [self setUpdateFrequency:updateFrequency];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _estimatedMinimumFrequency, _estimatedMaximumFrequency, _estimatedInitialFrequency, _medianFilterSize, _downsamplingFactor, _updateFrequency];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"pitchamdf("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@, kUnused pitchamdf ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_medianFilterSizeForAmplitude = akp(0);        
    
    if ([_input class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@, ", _input];
    } else {
        [inputsString appendFormat:@"AKAudio(%@), ", _input];
    }

    [inputsString appendFormat:@"%@, ", _estimatedMinimumFrequency];
    
    [inputsString appendFormat:@"%@, ", _estimatedMaximumFrequency];
    
    [inputsString appendFormat:@"%@, ", _estimatedInitialFrequency];
    
    [inputsString appendFormat:@"%@, ", _medianFilterSize];
    
    [inputsString appendFormat:@"%@, ", _downsamplingFactor];
    
    [inputsString appendFormat:@"%@, ", _updateFrequency];
    
    [inputsString appendFormat:@"%@", _medianFilterSizeForAmplitude];
    return inputsString;
}

@end
