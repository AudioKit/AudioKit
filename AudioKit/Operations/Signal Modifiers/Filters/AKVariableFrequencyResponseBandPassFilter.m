//
//  AKVariableFrequencyResponseBandPassFilter.m
//  AudioKit
//
//  Auto-generated on 2/8/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's resonz:
//  http://www.csounds.com/manual/html/resonz.html
//

#import "AKVariableFrequencyResponseBandPassFilter.h"
#import "AKManager.h"

@implementation AKVariableFrequencyResponseBandPassFilter
{
    AKParameter * _audioSource;
}

+ (AKConstant *)scalingFactorNone { return akp(0); }
+ (AKConstant *)scalingFactorPeak { return akp(1); }
+ (AKConstant *)scalingFactorRMS  { return akp(2); }

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                    cutoffFrequency:(AKParameter *)cutoffFrequency
                          bandwidth:(AKParameter *)bandwidth
                      scalingFactor:(AKConstant *)scalingFactor
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _cutoffFrequency = cutoffFrequency;
        _bandwidth = bandwidth;
        _scalingFactor = scalingFactor;
    }
    return self;
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        // Default Values
        _cutoffFrequency = akp(1000);
        _bandwidth = akp(10);
        _scalingFactor = akp(0);
    }
    return self;
}

+ (instancetype)filterWithAudioSource:(AKParameter *)audioSource
{
    return [[AKVariableFrequencyResponseBandPassFilter alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency {
    _cutoffFrequency = cutoffFrequency;
}
- (void)setOptionalBandwidth:(AKParameter *)bandwidth {
    _bandwidth = bandwidth;
}
- (void)setOptionalScalingFactor:(AKConstant *)scalingFactor {
    _scalingFactor = scalingFactor;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ resonz ", self];

    if ([_audioSource class] == [AKAudio class]) {
        [csdString appendFormat:@"%@, ", _audioSource];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _audioSource];
    }

    if ([_cutoffFrequency class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _cutoffFrequency];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _cutoffFrequency];
    }

    if ([_bandwidth class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _bandwidth];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _bandwidth];
    }

    [csdString appendFormat:@"%@", _scalingFactor];
    return csdString;
}

@end
