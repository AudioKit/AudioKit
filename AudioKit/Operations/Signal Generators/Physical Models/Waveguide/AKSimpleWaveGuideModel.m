//
//  AKSimpleWaveGuideModel.m
//  AudioKit
//
//  Auto-generated on 12/23/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's wguide1:
//  http://www.csounds.com/manual/html/wguide1.html
//

#import "AKSimpleWaveGuideModel.h"
#import "AKManager.h"

@implementation AKSimpleWaveGuideModel
{
    AKParameter * _audioSource;
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                          frequency:(AKParameter *)frequency
                             cutoff:(AKParameter *)cutoff
                           feedback:(AKParameter *)feedback
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _frequency = frequency;
        _cutoff = cutoff;
        _feedback = feedback;
    }
    return self;
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        // Default Values
        _frequency = akp(440);    
        _cutoff = akp(3000);    
        _feedback = akp(0.8);    
    }
    return self;
}

+ (instancetype)audioWithAudioSource:(AKParameter *)audioSource
{
    return [[AKSimpleWaveGuideModel alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalFrequency:(AKParameter *)frequency {
    _frequency = frequency;
}
- (void)setOptionalCutoff:(AKParameter *)cutoff {
    _cutoff = cutoff;
}
- (void)setOptionalFeedback:(AKParameter *)feedback {
    _feedback = feedback;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ wguide1 AKAudio(%@), %@, AKControl(%@), AKControl(%@)",
            self,
            _audioSource,
            _frequency,
            _cutoff,
            _feedback];
}

@end
