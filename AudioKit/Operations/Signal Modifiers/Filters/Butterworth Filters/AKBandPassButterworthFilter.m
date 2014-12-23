//
//  AKBandPassButterworthFilter.m
//  AudioKit
//
//  Auto-generated on 12/20/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's butterbp:
//  http://www.csounds.com/manual/html/butterbp.html
//

#import "AKBandPassButterworthFilter.h"
#import "AKManager.h"

@implementation AKBandPassButterworthFilter
{
    AKAudio *_audioSource;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                    centerFrequency:(AKControl *)centerFrequency
                          bandwidth:(AKControl *)bandwidth
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _centerFrequency = centerFrequency;
        _bandwidth = bandwidth;
    }
    return self;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        // Default Values
        _centerFrequency = akp(2000);    
        _bandwidth = akp(100);    
    }
    return self;
}

+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource
{
    return [[AKBandPassButterworthFilter alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalCenterFrequency:(AKControl *)centerFrequency {
    _centerFrequency = centerFrequency;
}
- (void)setOptionalBandwidth:(AKControl *)bandwidth {
    _bandwidth = bandwidth;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ butterbp %@, %@, %@",
            self,
            _audioSource,
            _centerFrequency,
            _bandwidth];
}

@end
