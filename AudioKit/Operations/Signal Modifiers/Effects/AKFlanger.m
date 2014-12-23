//
//  AKFlanger.m
//  AudioKit
//
//  Auto-generated on 12/23/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's flanger:
//  http://www.csounds.com/manual/html/flanger.html
//

#import "AKFlanger.h"
#import "AKManager.h"

@implementation AKFlanger
{
    AKParameter * _audioSource;
    AKParameter * _delayTime;
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                          delayTime:(AKParameter *)delayTime
                           feedback:(AKParameter *)feedback
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _delayTime = delayTime;
        _feedback = feedback;
    }
    return self;
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                          delayTime:(AKParameter *)delayTime
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

+ (instancetype)audioWithAudioSource:(AKParameter *)audioSource
                          delayTime:(AKParameter *)delayTime
{
    return [[AKFlanger alloc] initWithAudioSource:audioSource
                          delayTime:delayTime];
}

- (void)setOptionalFeedback:(AKParameter *)feedback {
    _feedback = feedback;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ flanger AKAudio(%@), AKAudio(%@), AKControl(%@)",
            self,
            _audioSource,
            _delayTime,
            _feedback];
}

@end
