//
//  AKLowPassFilter.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
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
    }
    return self;
}

+ (instancetype)filterWithAudioSource:(AKParameter *)audioSource
{
    return [[AKLowPassFilter alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalHalfPowerPoint:(AKParameter *)halfPowerPoint {
    _halfPowerPoint = halfPowerPoint;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ tone ", self];

    if ([_audioSource class] == [AKAudio class]) {
        [csdString appendFormat:@"%@, ", _audioSource];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _audioSource];
    }

    if ([_halfPowerPoint class] == [AKControl class]) {
        [csdString appendFormat:@"%@", _halfPowerPoint];
    } else {
        [csdString appendFormat:@"AKControl(%@)", _halfPowerPoint];
    }
return csdString;
}

@end
