//
//  AKFlanger.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's flanger:
//  http://www.csounds.com/manual/html/flanger.html
//

#import "AKFlanger.h"
#import "AKManager.h"

@implementation AKFlanger
{
    AKAudio *_audioSource;
    AKAudio *_delayTime;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                          delayTime:(AKAudio *)delayTime
                           feedback:(AKControl *)feedback
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _delayTime = delayTime;
        _feedback = feedback;
    }
    return self;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                          delayTime:(AKAudio *)delayTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _delayTime = delayTime;
        // Default Values
        _feedback = akp(0);    
    }
    return self;
}

+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource
                          delayTime:(AKAudio *)delayTime
{
    return [[AKFlanger alloc] initWithAudioSource:audioSource
                          delayTime:delayTime];
}

- (void)setOptionalFeedback:(AKControl *)feedback {
    _feedback = feedback;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ flanger %@, %@, %@",
            self,
            _audioSource,
            _delayTime,
            _feedback];
}

@end
