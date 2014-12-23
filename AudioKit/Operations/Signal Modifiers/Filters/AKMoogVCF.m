//
//  AKMoogVCF.m
//  AudioKit
//
//  Auto-generated on 12/19/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's moogvcf2:
//  http://www.csounds.com/manual/html/moogvcf2.html
//

#import "AKMoogVCF.h"
#import "AKManager.h"

@implementation AKMoogVCF
{
    AKAudio *_audioSource;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                    cutoffFrequency:(AKParameter *)cutoffFrequency
                          resonance:(AKParameter *)resonance
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
        _cutoffFrequency = akp(1000);    
        _resonance = akp(0.5);    
    }
    return self;
}

+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource
{
    return [[AKMoogVCF alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency {
    _cutoffFrequency = cutoffFrequency;
}
- (void)setOptionalResonance:(AKParameter *)resonance {
    _resonance = resonance;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ moogvcf2 %@, %@, %@",
            self,
            _audioSource,
            _cutoffFrequency,
            _resonance];
}

@end
