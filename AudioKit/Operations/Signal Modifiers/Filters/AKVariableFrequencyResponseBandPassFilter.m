//
//  AKVariableFrequencyResponseBandPassFilter.m
//  AudioKit
//
//  Auto-generated on 12/22/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's resonz:
//  http://www.csounds.com/manual/html/resonz.html
//

#import "AKVariableFrequencyResponseBandPassFilter.h"
#import "AKManager.h"

@implementation AKVariableFrequencyResponseBandPassFilter
{
    AKAudio * _audioSource;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                    cutoffFrequency:(AKControl *)cutoffFrequency
                          bandwidth:(AKControl *)bandwidth
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _cutoffFrequency = cutoffFrequency;
        _bandwidth = bandwidth;
    }
    return self;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
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

+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource
{
    return [[AKVariableFrequencyResponseBandPassFilter alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalCutoffFrequency:(AKControl *)cutoffFrequency {
    _cutoffFrequency = cutoffFrequency;
}
- (void)setOptionalBandwidth:(AKControl *)bandwidth {
    _bandwidth = bandwidth;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ resonz %@, %@, %@",
            self,
            _audioSource,
            _cutoffFrequency,
            _bandwidth];
}

@end
