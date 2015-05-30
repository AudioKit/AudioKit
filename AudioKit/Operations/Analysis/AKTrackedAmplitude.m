//
//  AKTrackedAmplitude.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Customized by Aurelius Prochazka on 5/29/15 to scale the amplitude by sqrt 2.
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
        [csdString appendFormat:@"%@*1.414, ", _audioSource];
    } else {
        [csdString appendFormat:@"AKAudio(%@*1.414), ", _audioSource];
    }

    [csdString appendFormat:@"%@", _halfPowerPoint];
    return csdString;
}

@end
