//
//  AKMoogLadder.m
//  AudioKit
//
//  Auto-generated on 12/21/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's moogladder:
//  http://www.csounds.com/manual/html/moogladder.html
//

#import "AKMoogLadder.h"
#import "AKManager.h"

@implementation AKMoogLadder
{
    AKAudio *_audioSource;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                    cutoffFrequency:(AKControl *)cutoffFrequency
                          resonance:(AKControl *)resonance
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
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
        _cutoffFrequency = akp(9000);
        _resonance = akp(0.5);    
    }
    return self;
}

+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource
{
    return [[AKMoogLadder alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalCutoffFrequency:(AKControl *)cutoffFrequency {
    _cutoffFrequency = cutoffFrequency;
}
- (void)setOptionalResonance:(AKControl *)resonance {
    _resonance = resonance;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ moogladder %@, %@, %@",
            self,
            _audioSource,
            _cutoffFrequency,
            _resonance];
}

@end
