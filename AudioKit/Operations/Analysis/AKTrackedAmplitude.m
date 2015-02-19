//
//  AKTrackedAmplitude.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's rms:
//  http://www.csounds.com/manual/html/rms.html
//

#import "AKTrackedAmplitude.h"
#import "AKManager.h"

@implementation AKTrackedAmplitude
{
    AKParameter * _audioSource;
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                     halfPowerPoint:(AKConstant *)halfPowerPoint
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _halfPowerPoint = halfPowerPoint;
        self.state = @"connectable";
        self.dependencies = @[audioSource];
    }
    return self;
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        // Default Values
        _halfPowerPoint = akp(10);
        self.state = @"connectable";
        self.dependencies = @[audioSource];
    }
    return self;
}

+ (instancetype)amplitudeWithAudioSource:(AKParameter *)audioSource
{
    return [[AKTrackedAmplitude alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalHalfPowerPoint:(AKConstant *)halfPowerPoint {
    _halfPowerPoint = halfPowerPoint;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ rms ", self];

    if ([_audioSource class] == [AKAudio class]) {
        [csdString appendFormat:@"%@, ", _audioSource];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _audioSource];
    }

    [csdString appendFormat:@"%@", _halfPowerPoint];
    return csdString;
}

@end
