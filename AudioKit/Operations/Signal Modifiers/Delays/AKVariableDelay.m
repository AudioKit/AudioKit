//
//  AKVariableDelay.m
//  AudioKit
//
//  Auto-generated on 12/25/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's vdelay3:
//  http://www.csounds.com/manual/html/vdelay3.html
//

#import "AKVariableDelay.h"
#import "AKManager.h"

@implementation AKVariableDelay
{
    AKParameter * _audioSource;
    AKParameter * _delayTime;
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                          delayTime:(AKParameter *)delayTime
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

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                          delayTime:(AKParameter *)delayTime
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

+ (instancetype)audioWithAudioSource:(AKParameter *)audioSource
                          delayTime:(AKParameter *)delayTime
{
    return [[AKVariableDelay alloc] initWithAudioSource:audioSource
                          delayTime:delayTime];
}

- (void)setOptionalMaximumDelayTime:(AKConstant *)maximumDelayTime {
    _maximumDelayTime = maximumDelayTime;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ vdelay3 ", self];

    if ([_audioSource isKindOfClass:[AKAudio class]] ) {
        [csdString appendFormat:@"%@, ", _audioSource];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _audioSource];
    }

    if ([_delayTime isKindOfClass:[AKAudio class]] ) {
        [csdString appendFormat:@"%@, ", _delayTime];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _delayTime];
    }

    [csdString appendFormat:@"%@", _maximumDelayTime];
    return csdString;
}

@end
