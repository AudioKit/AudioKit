//
//  AKFlatFrequencyResponseReverb.m
//  AudioKit
//
//  Auto-generated on 12/19/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's alpass:
//  http://www.csounds.com/manual/html/alpass.html
//

#import "AKFlatFrequencyResponseReverb.h"
#import "AKManager.h"

@implementation AKFlatFrequencyResponseReverb
{
    AKAudio *_audioSource;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                  reverberationTime:(AKControl *)reverberationTime
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

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
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

+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource
{
    return [[AKFlatFrequencyResponseReverb alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalReverberationTime:(AKControl *)reverberationTime {
    _reverberationTime = reverberationTime;
}
- (void)setOptionalLoopTime:(AKConstant *)loopTime {
    _loopTime = loopTime;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ alpass %@, %@, %@",
            self,
            _audioSource,
            _reverberationTime,
            _loopTime];
}

@end
