//
//  AKFlatFrequencyResponseReverb.m
//  AudioKit
//
//  Auto-generated on 12/25/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's alpass:
//  http://www.csounds.com/manual/html/alpass.html
//

#import "AKFlatFrequencyResponseReverb.h"
#import "AKManager.h"

@implementation AKFlatFrequencyResponseReverb
{
    AKParameter * _audioSource;
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                  reverberationTime:(AKParameter *)reverberationTime
                           loopTime:(AKConstant *)loopTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _reverberationTime = reverberationTime;
        _loopTime = loopTime;
    }
    return self;
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        // Default Values
        _reverberationTime = akp(3);
        _loopTime = akp(0.1);
    }
    return self;
}

+ (instancetype)audioWithAudioSource:(AKParameter *)audioSource
{
    return [[AKFlatFrequencyResponseReverb alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalReverberationTime:(AKParameter *)reverberationTime {
    _reverberationTime = reverberationTime;
}
- (void)setOptionalLoopTime:(AKConstant *)loopTime {
    _loopTime = loopTime;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ alpass ", self];

    if ([_audioSource isKindOfClass:[AKAudio class]] ) {
        [csdString appendFormat:@"%@, ", _audioSource];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _audioSource];
    }

    if ([_reverberationTime isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _reverberationTime];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _reverberationTime];
    }

    [csdString appendFormat:@"%@", _loopTime];
    return csdString;
}

@end
