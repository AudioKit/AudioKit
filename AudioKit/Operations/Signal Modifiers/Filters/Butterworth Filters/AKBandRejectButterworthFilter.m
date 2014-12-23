//
//  AKBandRejectButterworthFilter.m
//  AudioKit
//
//  Auto-generated on 12/23/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's butterbr:
//  http://www.csounds.com/manual/html/butterbr.html
//

#import "AKBandRejectButterworthFilter.h"
#import "AKManager.h"

@implementation AKBandRejectButterworthFilter
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
        _centerFrequency = akp(3000);    
        _bandwidth = akp(2000);    
    }
    return self;
}

+ (instancetype)audioWithAudioSource:(AKParameter *)audioSource
{
    return [[AKBandRejectButterworthFilter alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalCenterFrequency:(AKParameter *)centerFrequency {
    _centerFrequency = centerFrequency;
}
- (void)setOptionalBandwidth:(AKParameter *)bandwidth {
    _bandwidth = bandwidth;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ butterbr AKAudio(%@), AKControl(%@), AKControl(%@)",
            self,
            _audioSource,
            _centerFrequency,
            _bandwidth];
}

@end
