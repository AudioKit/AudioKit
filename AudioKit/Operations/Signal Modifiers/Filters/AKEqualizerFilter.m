//
//  AKEqualizerFilter.m
//  AudioKit
//
//  Auto-generated on 12/24/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's eqfil:
//  http://www.csounds.com/manual/html/eqfil.html
//

#import "AKEqualizerFilter.h"
#import "AKManager.h"

@implementation AKEqualizerFilter
{
    AKParameter * _audioSource;
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                    centerFrequency:(AKParameter *)centerFrequency
                          bandwidth:(AKParameter *)bandwidth
                               gain:(AKParameter *)gain
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _centerFrequency = centerFrequency;
        _bandwidth = bandwidth;
        _gain = gain;
    }
    return self;
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        // Default Values
        _centerFrequency = akp(1000);    
        _bandwidth = akp(100);    
        _gain = akp(10);    
    }
    return self;
}

+ (instancetype)audioWithAudioSource:(AKParameter *)audioSource
{
    return [[AKEqualizerFilter alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalCenterFrequency:(AKParameter *)centerFrequency {
    _centerFrequency = centerFrequency;
}
- (void)setOptionalBandwidth:(AKParameter *)bandwidth {
    _bandwidth = bandwidth;
}
- (void)setOptionalGain:(AKParameter *)gain {
    _gain = gain;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ eqfil AKAudio(%@), AKControl(%@), AKControl(%@), AKControl(%@)",
            self,
            _audioSource,
            _centerFrequency,
            _bandwidth,
            _gain];
}

@end
