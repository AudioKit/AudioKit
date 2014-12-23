//
//  AKThreePoleLowpassFilter.m
//  AudioKit
//
//  Auto-generated on 12/21/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's lpf18:
//  http://www.csounds.com/manual/html/lpf18.html
//

#import "AKThreePoleLowpassFilter.h"
#import "AKManager.h"

@implementation AKThreePoleLowpassFilter
{
    AKAudio *_audioSource;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                         distortion:(AKControl *)distortion
                    cutoffFrequency:(AKControl *)cutoffFrequency
                          resonance:(AKControl *)resonance
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _distortion = distortion;
        _cutoffFrequency = cutoffFrequency;
        _resonance = resonance;
    }
    return self;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        // Default Values
        _distortion = akp(0.5);    
        _cutoffFrequency = akp(1500);    
        _resonance = akp(0.5);    
    }
    return self;
}

+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource
{
    return [[AKThreePoleLowpassFilter alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalDistortion:(AKControl *)distortion {
    _distortion = distortion;
}
- (void)setOptionalCutoffFrequency:(AKControl *)cutoffFrequency {
    _cutoffFrequency = cutoffFrequency;
}
- (void)setOptionalResonance:(AKControl *)resonance {
    _resonance = resonance;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ lpf18 %@, %@, %@, %@",
            self,
            _audioSource,
            _cutoffFrequency,
            _resonance,
            _distortion];
}

@end
