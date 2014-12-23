//
//  AKVariableFrequencyResponseBandPassFilter.m
//  AudioKit
//
//  Auto-generated on 12/23/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
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

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                    cutoffFrequency:(AKParameter *)cutoffFrequency
                          bandwidth:(AKParameter *)bandwidth
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _cutoffFrequency = cutoffFrequency;
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
        _cutoffFrequency = akp(1000);    
        _bandwidth = akp(10);    
    }
    return self;
}

+ (instancetype)audioWithAudioSource:(AKParameter *)audioSource
{
    return [[AKVariableFrequencyResponseBandPassFilter alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency {
    _cutoffFrequency = cutoffFrequency;
}
- (void)setOptionalBandwidth:(AKParameter *)bandwidth {
    _bandwidth = bandwidth;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ resonz AKAudio(%@), AKControl(%@), AKControl(%@)",
            self,
            _audioSource,
            _cutoffFrequency,
            _bandwidth];
}

@end
