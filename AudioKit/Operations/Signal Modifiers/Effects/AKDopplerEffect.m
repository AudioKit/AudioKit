//
//  AKDopplerEffect.m
//  AudioKit
//
//  Auto-generated on 12/25/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's doppler:
//  http://www.csounds.com/manual/html/doppler.html
//

#import "AKDopplerEffect.h"
#import "AKManager.h"

@implementation AKDopplerEffect
{
    AKParameter * _audioSource;
    AKParameter * _sourcePosition;
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                     sourcePosition:(AKParameter *)sourcePosition
                        micPosition:(AKParameter *)micPosition
          smoothingFilterUpdateRate:(AKConstant *)smoothingFilterUpdateRate
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _sourcePosition = sourcePosition;
        _micPosition = micPosition;
        _smoothingFilterUpdateRate = smoothingFilterUpdateRate;
    }
    return self;
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                     sourcePosition:(AKParameter *)sourcePosition
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _sourcePosition = sourcePosition;
        // Default Values
        _micPosition = akp(0);
        _smoothingFilterUpdateRate = akp(6);
    }
    return self;
}

+ (instancetype)audioWithAudioSource:(AKParameter *)audioSource
                     sourcePosition:(AKParameter *)sourcePosition
{
    return [[AKDopplerEffect alloc] initWithAudioSource:audioSource
                     sourcePosition:sourcePosition];
}

- (void)setOptionalMicPosition:(AKParameter *)micPosition {
    _micPosition = micPosition;
}
- (void)setOptionalSmoothingFilterUpdateRate:(AKConstant *)smoothingFilterUpdateRate {
    _smoothingFilterUpdateRate = smoothingFilterUpdateRate;
}

- (NSString *)stringForCSD {
    // Constant Values  
    AKConstant *_soundSpeed = akp(340.29);        
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ doppler ", self];

    if ([_audioSource isKindOfClass:[AKAudio class]] ) {
        [csdString appendFormat:@"%@, ", _audioSource];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _audioSource];
    }

    if ([_sourcePosition isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _sourcePosition];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _sourcePosition];
    }

    if ([_micPosition isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _micPosition];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _micPosition];
    }

    [csdString appendFormat:@"%@, ", _soundSpeed];
    
    [csdString appendFormat:@"%@", _smoothingFilterUpdateRate];
    return csdString;
}

@end
