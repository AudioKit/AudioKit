//
//  AKAntiresonantFilter.m
//  AudioKit
//
//  Auto-generated on 8/16/15.
//  Customized by Daniel Clelland on 8/30/15 to include tival() and peak scaling.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's areson:
//  http://www.csounds.com/manual/html/areson.html
//

#import "AKAntiresonantFilter.h"
#import "AKManager.h"

@implementation AKAntiresonantFilter
{
    AKParameter * _audioSource;
}

- (instancetype)initWithInput:(AKParameter *)audioSource
              centerFrequency:(AKParameter *)centerFrequency
                    bandwidth:(AKParameter *)bandwidth
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _centerFrequency = centerFrequency;
        _bandwidth = bandwidth;
        [self setUpConnections];
    }
    return self;
}

- (instancetype)initWithInput:(AKParameter *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        // Default Values
        _centerFrequency = akp(1000);
        _bandwidth = akp(10);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)filterWithInput:(AKParameter *)audioSource
{
    return [[AKAntiresonantFilter alloc] initWithInput:audioSource];
}

- (void)setCenterFrequency:(AKParameter *)centerFrequency {
    _centerFrequency = centerFrequency;
    [self setUpConnections];
}

- (void)setOptionalCenterFrequency:(AKParameter *)centerFrequency {
    [self setCenterFrequency:centerFrequency];
}

- (void)setBandwidth:(AKParameter *)bandwidth {
    _bandwidth = bandwidth;
    [self setUpConnections];
}

- (void)setOptionalBandwidth:(AKParameter *)bandwidth {
    [self setBandwidth:bandwidth];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_audioSource, _centerFrequency, _bandwidth];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];
    
    [inlineCSDString appendString:@"areson("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];
    
    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    [csdString appendFormat:@"%@ areson ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];
    
    
    if ([_audioSource class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@, ", _audioSource];
    } else {
        [inputsString appendFormat:@"AKAudio(%@), ", _audioSource];
    }
    
    if ([_centerFrequency class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _centerFrequency];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _centerFrequency];
    }
    
    if ([_bandwidth class] == [AKControl class]) {
        [inputsString appendFormat:@"%@", _bandwidth];
    } else {
        [inputsString appendFormat:@"AKControl(%@)", _bandwidth];
    }
    [inputsString appendString:@", 1, tival()"];
    return inputsString;
}

@end
