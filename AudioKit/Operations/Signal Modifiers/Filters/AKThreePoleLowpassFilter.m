//
//  AKThreePoleLowpassFilter.m
//  AudioKit
//
//  Auto-generated on 12/25/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's lpf18:
//  http://www.csounds.com/manual/html/lpf18.html
//

#import "AKThreePoleLowpassFilter.h"
#import "AKManager.h"

@implementation AKThreePoleLowpassFilter
{
    AKParameter * _audioSource;
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                         distortion:(AKParameter *)distortion
                    cutoffFrequency:(AKParameter *)cutoffFrequency
                          resonance:(AKParameter *)resonance
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

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
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

+ (instancetype)audioWithAudioSource:(AKParameter *)audioSource
{
    return [[AKThreePoleLowpassFilter alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalDistortion:(AKParameter *)distortion {
    _distortion = distortion;
}
- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency {
    _cutoffFrequency = cutoffFrequency;
}
- (void)setOptionalResonance:(AKParameter *)resonance {
    _resonance = resonance;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ lpf18 ", self];

    if ([_audioSource isKindOfClass:[AKAudio class]] ) {
        [csdString appendFormat:@"%@, ", _audioSource];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _audioSource];
    }

    if ([_cutoffFrequency isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _cutoffFrequency];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _cutoffFrequency];
    }

    if ([_resonance isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _resonance];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _resonance];
    }

    if ([_distortion isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@", _distortion];
    } else {
        [csdString appendFormat:@"AKControl(%@)", _distortion];
    }
return csdString;
}

@end
