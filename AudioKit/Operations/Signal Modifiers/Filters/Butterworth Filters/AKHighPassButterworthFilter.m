//
//  AKHighPassButterworthFilter.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/20/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's butterhp:
//  http://www.csounds.com/manual/html/butterhp.html
//

#import "AKHighPassButterworthFilter.h"
#import "AKManager.h"

@implementation AKHighPassButterworthFilter
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
        _cutoffFrequency = akp(500);    
    }
    return self;
}

+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource
{
    return [[AKHighPassButterworthFilter alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalCutoffFrequency:(AKControl *)cutoffFrequency {
    _cutoffFrequency = cutoffFrequency;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ butterhp %@, %@",
            self,
            _audioSource,
            _cutoffFrequency];
}

@end
