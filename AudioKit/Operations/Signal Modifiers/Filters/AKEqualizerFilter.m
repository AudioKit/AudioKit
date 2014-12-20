//
//  AKEqualizerFilter.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/19/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's eqfil:
//  http://www.csounds.com/manual/html/eqfil.html
//

#import "AKEqualizerFilter.h"
#import "AKManager.h"

@implementation AKEqualizerFilter
{
    AKAudio *_audioSource;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                    centerFrequency:(AKControl *)centerFrequency
                          bandwidth:(AKControl *)bandwidth
                               gain:(AKControl *)gain
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

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
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

+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource
{
    return [[AKEqualizerFilter alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalCenterFrequency:(AKControl *)centerFrequency {
    _centerFrequency = centerFrequency;
}
- (void)setOptionalBandwidth:(AKControl *)bandwidth {
    _bandwidth = bandwidth;
}
- (void)setOptionalGain:(AKControl *)gain {
    _gain = gain;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ eqfil %@, %@, %@, %@, %@",
            self,
            _audioSource,
            _centerFrequency,
            _bandwidth,
            _gain,
            _gain];
}

@end
