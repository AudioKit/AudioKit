//
//  AKParallelCombLowPassFilterReverb.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/19/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's nreverb:
//  http://www.csounds.com/manual/html/nreverb.html
//

#import "AKParallelCombLowPassFilterReverb.h"
#import "AKManager.h"

@implementation AKParallelCombLowPassFilterReverb
{
    AKAudio *_audioSource;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                           duration:(AKControl *)duration
           highFrequencyDiffusivity:(AKControl *)highFrequencyDiffusivity
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _duration = duration;
        _highFrequencyDiffusivity = highFrequencyDiffusivity;
    }
    return self;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
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

+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource
{
    return [[AKParallelCombLowPassFilterReverb alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalDuration:(AKControl *)duration {
    _duration = duration;
}
- (void)setOptionalHighFrequencyDiffusivity:(AKControl *)highFrequencyDiffusivity {
    _highFrequencyDiffusivity = highFrequencyDiffusivity;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ nreverb %@, %@, %@",
            self,
            _audioSource,
            _duration,
            _highFrequencyDiffusivity];
}

@end
