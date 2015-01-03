//
//  AKResonantFilter.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's reson:
//  http://www.csounds.com/manual/html/reson.html
//

#import "AKResonantFilter.h"
#import "AKManager.h"

@implementation AKResonantFilter
{
    AKParameter * _audioSource;
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                    centerFrequency:(AKParameter *)centerFrequency
                          bandwidth:(AKParameter *)bandwidth
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _centerFrequency = centerFrequency;
        _bandwidth = bandwidth;
    }
    return self;
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        // Default Values
        _centerFrequency = akp(1000);
        _bandwidth = akp(10);
    }
    return self;
}

+ (instancetype)filterWithAudioSource:(AKParameter *)audioSource
{
    return [[AKResonantFilter alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalCenterFrequency:(AKParameter *)centerFrequency {
    _centerFrequency = centerFrequency;
}
- (void)setOptionalBandwidth:(AKParameter *)bandwidth {
    _bandwidth = bandwidth;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ reson ", self];

    if ([_audioSource class] == [AKAudio class]) {
        [csdString appendFormat:@"%@, ", _audioSource];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _audioSource];
    }

    if ([_centerFrequency class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _centerFrequency];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _centerFrequency];
    }

    if ([_bandwidth class] == [AKControl class]) {
        [csdString appendFormat:@"%@", _bandwidth];
    } else {
        [csdString appendFormat:@"AKControl(%@)", _bandwidth];
    }
return csdString;
}

@end
