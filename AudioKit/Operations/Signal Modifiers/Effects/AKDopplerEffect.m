//
//  AKDopplerEffect.m
//  AudioKit
//
//  Auto-generated on 12/21/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's doppler:
//  http://www.csounds.com/manual/html/doppler.html
//

#import "AKDopplerEffect.h"
#import "AKManager.h"

@implementation AKDopplerEffect
{
    AKAudio *_audioSource;
    AKControl *_sourcePosition;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                     sourcePosition:(AKControl *)sourcePosition
                        micPosition:(AKControl *)micPosition
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

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                     sourcePosition:(AKControl *)sourcePosition
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

+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource
                     sourcePosition:(AKControl *)sourcePosition
{
    return [[AKDopplerEffect alloc] initWithAudioSource:audioSource
                     sourcePosition:sourcePosition];
}

- (void)setOptionalMicPosition:(AKControl *)micPosition {
    _micPosition = micPosition;
}
- (void)setOptionalSmoothingFilterUpdateRate:(AKConstant *)smoothingFilterUpdateRate {
    _smoothingFilterUpdateRate = smoothingFilterUpdateRate;
}

- (NSString *)stringForCSD {
    // Constant Values  
    AKConstant *_soundSpeed = akp(340.29);        
    return [NSString stringWithFormat:
            @"%@ doppler %@, %@, %@, %@, %@",
            self,
            _audioSource,
            _sourcePosition,
            _micPosition,
            _soundSpeed,
            _smoothingFilterUpdateRate];
}

@end
