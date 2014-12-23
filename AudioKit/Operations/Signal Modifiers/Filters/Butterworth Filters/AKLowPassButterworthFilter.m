//
//  AKLowPassButterworthFilter.m
//  AudioKit
//
//  Auto-generated on 12/20/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's butterlp:
//  http://www.csounds.com/manual/html/butterlp.html
//

#import "AKLowPassButterworthFilter.h"
#import "AKManager.h"

@implementation AKLowPassButterworthFilter
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
        _cutoffFrequency = akp(1000);    
    }
    return self;
}

+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource
{
    return [[AKLowPassButterworthFilter alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalCutoffFrequency:(AKControl *)cutoffFrequency {
    _cutoffFrequency = cutoffFrequency;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ butterlp %@, %@",
            self,
            _audioSource,
            _cutoffFrequency];
}

@end
