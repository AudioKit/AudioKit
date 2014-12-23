//
//  AKBandRejectButterworthFilter.m
//  AudioKit
//
//  Auto-generated on 12/20/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's butterbr:
//  http://www.csounds.com/manual/html/butterbr.html
//

#import "AKBandRejectButterworthFilter.h"
#import "AKManager.h"

@implementation AKBandRejectButterworthFilter
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
        _centerFrequency = akp(3000);    
        _bandwidth = akp(2000);    
    }
    return self;
}

+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource
{
    return [[AKBandRejectButterworthFilter alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalCenterFrequency:(AKControl *)centerFrequency {
    _centerFrequency = centerFrequency;
}
- (void)setOptionalBandwidth:(AKControl *)bandwidth {
    _bandwidth = bandwidth;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ butterbr %@, %@, %@",
            self,
            _audioSource,
            _centerFrequency,
            _bandwidth];
}

@end
