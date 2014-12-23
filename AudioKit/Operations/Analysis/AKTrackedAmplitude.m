//
//  AKTrackedAmplitude.m
//  AudioKit
//
//  Auto-generated on 12/22/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's rms:
//  http://www.csounds.com/manual/html/rms.html
//

#import "AKTrackedAmplitude.h"
#import "AKManager.h"

@implementation AKTrackedAmplitude
{
    AKAudio * _audioSource;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                     halfPowerPoint:(AKConstant *)halfPowerPoint
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _halfPowerPoint = halfPowerPoint;
    }
    return self;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        // Default Values
        _halfPowerPoint = akp(10);    
    }
    return self;
}

+ (instancetype)controlWithAudioSource:(AKAudio *)audioSource
{
    return [[AKTrackedAmplitude alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalHalfPowerPoint:(AKConstant *)halfPowerPoint {
    _halfPowerPoint = halfPowerPoint;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ rms %@, %@",
            self,
            _audioSource,
            _halfPowerPoint];
}

@end
