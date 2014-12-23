//
//  AKSimpleWaveGuideModel.m
//  AudioKit
//
//  Auto-generated on 11/30/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's wguide1:
//  http://www.csounds.com/manual/html/wguide1.html
//

#import "AKSimpleWaveGuideModel.h"
#import "AKManager.h"

@implementation AKSimpleWaveGuideModel
{
    AKAudio *_audioSource;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                          frequency:(AKParameter *)frequency
                             cutoff:(AKControl *)cutoff
                           feedback:(AKControl *)feedback
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

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        
        // Default Values
        _frequency = akp(440);
        _cutoff = akp(3000);
        _feedback = akp(0);
    }
    return self;
}

+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource
{
    return [[AKSimpleWaveGuideModel alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalFrequency:(AKParameter *)frequency {
    _frequency = frequency;
}

- (void)setOptionalCutoff:(AKControl *)cutoff {
    _cutoff = cutoff;
}

- (void)setOptionalFeedback:(AKControl *)feedback {
    _feedback = feedback;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ wguide1 %@, %@, %@, %@",
            self,
            _audioSource,
            _frequency,
            _cutoff,
            _feedback];
}


@end
