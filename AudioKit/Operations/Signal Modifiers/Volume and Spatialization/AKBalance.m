//
//  AKBalance.m
//  AudioKit
//
//  Auto-generated on 12/21/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's balance:
//  http://www.csounds.com/manual/html/balance.html
//

#import "AKBalance.h"
#import "AKManager.h"

@implementation AKBalance
{
    AKAudio *_audioSource;
    AKAudio *_comparatorAudioSource;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
              comparatorAudioSource:(AKAudio *)comparatorAudioSource
                     halfPowerPoint:(AKConstant *)halfPowerPoint
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _comparatorAudioSource = comparatorAudioSource;
        _halfPowerPoint = halfPowerPoint;
    }
    return self;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
              comparatorAudioSource:(AKAudio *)comparatorAudioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _comparatorAudioSource = comparatorAudioSource;
        // Default Values
        _halfPowerPoint = akp(10);    
    }
    return self;
}

+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource
              comparatorAudioSource:(AKAudio *)comparatorAudioSource
{
    return [[AKBalance alloc] initWithAudioSource:audioSource
              comparatorAudioSource:comparatorAudioSource];
}

- (void)setOptionalHalfPowerPoint:(AKConstant *)halfPowerPoint {
    _halfPowerPoint = halfPowerPoint;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ balance %@, %@, %@",
            self,
            _audioSource,
            _comparatorAudioSource,
            _halfPowerPoint];
}

@end
