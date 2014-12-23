//
//  AKVariableDelay.m
//  AudioKit
//
//  Auto-generated on 12/21/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's vdelay3:
//  http://www.csounds.com/manual/html/vdelay3.html
//

#import "AKVariableDelay.h"
#import "AKManager.h"

@implementation AKVariableDelay
{
    AKAudio *_audioSource;
    AKAudio *_delayTime;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                          delayTime:(AKAudio *)delayTime
                   maximumDelayTime:(AKConstant *)maximumDelayTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _delayTime = delayTime;
        _maximumDelayTime = maximumDelayTime;
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
        _maximumDelayTime = akp(2000);    
    }
    return self;
}

+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource
                          delayTime:(AKAudio *)delayTime
{
    return [[AKVariableDelay alloc] initWithAudioSource:audioSource
                          delayTime:delayTime];
}

- (void)setOptionalMaximumDelayTime:(AKConstant *)maximumDelayTime {
    _maximumDelayTime = maximumDelayTime;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ vdelay3 %@, %@, %@",
            self,
            _audioSource,
            _delayTime,
            _maximumDelayTime];
}

@end
