//
//  AKBandRejectButterworthFilter.m
//  AudioKit
//
//  Auto-generated on 12/25/14.
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
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ butterbr ", self];

    if ([_audioSource isKindOfClass:[AKAudio class]] ) {
        [csdString appendFormat:@"%@, ", _audioSource];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _audioSource];
    }

    if ([_centerFrequency isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _centerFrequency];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _centerFrequency];
    }

    if ([_bandwidth isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@", _bandwidth];
    } else {
        [csdString appendFormat:@"AKControl(%@)", _bandwidth];
    }
return csdString;
}

@end
