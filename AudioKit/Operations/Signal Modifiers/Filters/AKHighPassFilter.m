//
//  AKHighPassFilter.m
//  AudioKit
//
//  Auto-generated on 12/19/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's atone:
//  http://www.csounds.com/manual/html/atone.html
//

#import "AKHighPassFilter.h"
#import "AKManager.h"

@implementation AKHighPassFilter
{
    AKAudio *_audioSource;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                    cutoffFrequency:(AKControl *)cutoffFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _cutoffFrequency = cutoffFrequency;
    }
    return self;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        // Default Values
        _cutoffFrequency = akp(4000);    
    }
    return self;
}

+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource
{
    return [[AKHighPassFilter alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalCutoffFrequency:(AKControl *)cutoffFrequency {
    _cutoffFrequency = cutoffFrequency;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ atone %@, %@",
            self,
            _audioSource,
            _cutoffFrequency];
}

@end
