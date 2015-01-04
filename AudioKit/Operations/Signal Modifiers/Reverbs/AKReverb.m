//
//  AKReverb.m
//  AudioKit
//
//  Auto-generated on 12/24/14.
//  Customized by Aurelius Prochazka on 12/24/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's reverbsc:
//  http://www.csounds.com/manual/html/reverbsc.html
//

#import "AKReverb.h"
#import "AKManager.h"

@implementation AKReverb
{
    AKParameter * _audioSourceLeftChannel;
    AKParameter * _audioSourceRightChannel;
}

- (instancetype)initWithInput:(AKParameter *)input
                     feedback:(AKParameter *)feedback
              cutoffFrequency:(AKParameter *)cutoffFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSourceLeftChannel = input;
        _audioSourceRightChannel = input;
        _feedback = feedback;
        _cutoffFrequency = cutoffFrequency;
    }
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSourceLeftChannel = input;
        _audioSourceRightChannel = input;
        // Default Values
        _feedback = akp(0.6);    
        _cutoffFrequency = akp(4000);    
    }
    return self;
}

+ (instancetype)reverbWithInput:(AKParameter *)input
{
    return [[AKReverb alloc] initWithInput:input];
}


- (instancetype)initWithStereoInput:(AKStereoAudio *)input
                           feedback:(AKParameter *)feedback
                    cutoffFrequency:(AKParameter *)cutoffFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSourceLeftChannel = input.leftOutput;
        _audioSourceRightChannel = input.rightOutput;
        _feedback = feedback;
        _cutoffFrequency = cutoffFrequency;
    }
    return self;
}

- (instancetype)initWithStereoInput:(AKStereoAudio *)input
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSourceLeftChannel = input.leftOutput;
        _audioSourceRightChannel = input.rightOutput;
        // Default Values
        _feedback = akp(0.6);
        _cutoffFrequency = akp(4000);
    }
    return self;
}

+ (instancetype)reverbWithStereoInput:(AKStereoAudio *)input
{
    return [[AKReverb alloc] initWithStereoInput:input];
}


- (void)setOptionalFeedback:(AKParameter *)feedback {
    _feedback = feedback;
}
- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency {
    _cutoffFrequency = cutoffFrequency;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ reverbsc AKAudio(%@), AKAudio(%@), AKControl(%@), AKControl(%@), 0, 0, tival()",
            self,
            _audioSourceLeftChannel,
            _audioSourceRightChannel,
            _feedback,
            _cutoffFrequency];
}

@end
