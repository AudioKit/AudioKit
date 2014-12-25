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

- (instancetype)initWithAudioSourceLeftChannel:(AKParameter *)audioSourceLeftChannel
                       audioSourceRightChannel:(AKParameter *)audioSourceRightChannel
                                      feedback:(AKParameter *)feedback
                               cutoffFrequency:(AKParameter *)cutoffFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSourceLeftChannel = audioSourceLeftChannel;
        _audioSourceRightChannel = audioSourceRightChannel;
        _feedback = feedback;
        _cutoffFrequency = cutoffFrequency;
    }
    return self;
}

- (instancetype)initWithAudioSourceLeftChannel:(AKParameter *)audioSourceLeftChannel
                       audioSourceRightChannel:(AKParameter *)audioSourceRightChannel
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSourceLeftChannel = audioSourceLeftChannel;
        _audioSourceRightChannel = audioSourceRightChannel;
        // Default Values
        _feedback = akp(0.6);    
        _cutoffFrequency = akp(4000);    
    }
    return self;
}

+ (instancetype)stereoAudioWithAudioSourceLeftChannel:(AKParameter *)audioSourceLeftChannel
                              audioSourceRightChannel:(AKParameter *)audioSourceRightChannel
{
    return [[AKReverb alloc] initWithAudioSourceLeftChannel:audioSourceLeftChannel
                             audioSourceRightChannel:audioSourceRightChannel];
}


- (instancetype)initWithStereoAudioSource:(AKStereoAudio *)audioSource
                  audioSourceRightChannel:(AKParameter *)audioSourceRightChannel
                                 feedback:(AKParameter *)feedback
                          cutoffFrequency:(AKParameter *)cutoffFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSourceLeftChannel = audioSource.leftOutput;
        _audioSourceRightChannel = audioSource.rightOutput;
        _feedback = feedback;
        _cutoffFrequency = cutoffFrequency;
    }
    return self;
}

- (instancetype)initWithStereoAudioSource:(AKStereoAudio *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSourceLeftChannel = audioSource.leftOutput;
        _audioSourceRightChannel = audioSource.rightOutput;
        // Default Values
        _feedback = akp(0.6);
        _cutoffFrequency = akp(4000);
    }
    return self;
}

+ (instancetype)stereoAudioWithStereoAudioSource:(AKStereoAudio *)audioSource
{
    return [[AKReverb alloc] initWithAudioSourceLeftChannel:audioSource.leftOutput
                                    audioSourceRightChannel:audioSource.rightOutput];
}


- (void)setOptionalFeedback:(AKParameter *)feedback {
    _feedback = feedback;
}
- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency {
    _cutoffFrequency = cutoffFrequency;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ reverbsc AKAudio(%@), AKAudio(%@), AKControl(%@), AKControl(%@)",
            self,
            _audioSourceLeftChannel,
            _audioSourceRightChannel,
            _feedback,
            _cutoffFrequency];
}

@end
