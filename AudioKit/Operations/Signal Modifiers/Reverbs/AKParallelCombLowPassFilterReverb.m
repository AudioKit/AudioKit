//
//  AKParallelCombLowPassFilterReverb.m
//  AudioKit
//
//  Auto-generated on 12/23/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's nreverb:
//  http://www.csounds.com/manual/html/nreverb.html
//

#import "AKParallelCombLowPassFilterReverb.h"
#import "AKManager.h"

@implementation AKParallelCombLowPassFilterReverb
{
    AKParameter * _audioSource;
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                           duration:(AKParameter *)duration
           highFrequencyDiffusivity:(AKParameter *)highFrequencyDiffusivity
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _duration = duration;
        _highFrequencyDiffusivity = highFrequencyDiffusivity;
    }
    return self;
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        // Default Values
        _duration = akp(3);    
        _highFrequencyDiffusivity = akp(0.5);    
    }
    return self;
}

+ (instancetype)audioWithAudioSource:(AKParameter *)audioSource
{
    return [[AKParallelCombLowPassFilterReverb alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalDuration:(AKParameter *)duration {
    _duration = duration;
}
- (void)setOptionalHighFrequencyDiffusivity:(AKParameter *)highFrequencyDiffusivity {
    _highFrequencyDiffusivity = highFrequencyDiffusivity;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ nreverb AKAudio(%@), AKControl(%@), AKControl(%@)",
            self,
            _audioSource,
            _duration,
            _highFrequencyDiffusivity];
}

@end
