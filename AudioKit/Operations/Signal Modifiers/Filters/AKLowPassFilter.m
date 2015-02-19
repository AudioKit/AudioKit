//
//  AKLowPassFilter.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's tone:
//  http://www.csounds.com/manual/html/tone.html
//

#import "AKLowPassFilter.h"
#import "AKManager.h"

@implementation AKLowPassFilter
{
    AKParameter * _audioSource;
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                     halfPowerPoint:(AKParameter *)halfPowerPoint
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _halfPowerPoint = halfPowerPoint;
        [self setUpConnections];
}
    return self;
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        // Default Values
        _halfPowerPoint = akp(1000);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)filterWithAudioSource:(AKParameter *)audioSource
{
    return [[AKLowPassFilter alloc] initWithAudioSource:audioSource];
}

- (void)setHalfPowerPoint:(AKParameter *)halfPowerPoint {
    _halfPowerPoint = halfPowerPoint;
    [self setUpConnections];
}

- (void)setOptionalHalfPowerPoint:(AKParameter *)halfPowerPoint {
    [self setHalfPowerPoint:halfPowerPoint];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_audioSource, _halfPowerPoint];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"tone("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ tone ", self];
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

    if ([_halfPowerPoint class] == [AKControl class]) {
        [inputsString appendFormat:@"%@", _halfPowerPoint];
    } else {
        [inputsString appendFormat:@"AKControl(%@)", _halfPowerPoint];
    }
return inputsString;
}

@end
