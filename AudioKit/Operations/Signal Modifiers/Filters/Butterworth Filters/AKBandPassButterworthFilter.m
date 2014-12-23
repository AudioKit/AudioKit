//
//  AKBandPassButterworthFilter.m
//  AudioKit
//
//  Auto-generated on 12/23/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's butterbp:
//  http://www.csounds.com/manual/html/butterbp.html
//

#import "AKBandPassButterworthFilter.h"
#import "AKManager.h"

@implementation AKBandPassButterworthFilter
{
    AKParameter * _audioSource;
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                    centerFrequency:(AKParameter *)centerFrequency
                          bandwidth:(AKParameter *)bandwidth
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _centerFrequency = centerFrequency;
        _bandwidth = bandwidth;
    }
    return self;
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
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

+ (instancetype)audioWithAudioSource:(AKParameter *)audioSource
{
    return [[AKBandPassButterworthFilter alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalCenterFrequency:(AKParameter *)centerFrequency {
    _centerFrequency = centerFrequency;
}
- (void)setOptionalBandwidth:(AKParameter *)bandwidth {
    _bandwidth = bandwidth;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ butterbp AKAudio(%@), AKControl(%@), AKControl(%@)",
            self,
            _audioSource,
            _centerFrequency,
            _bandwidth];
}

@end
