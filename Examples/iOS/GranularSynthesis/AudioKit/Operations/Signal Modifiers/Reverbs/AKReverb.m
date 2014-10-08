//
//  AKReverb.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  This is an incomplete port of the Csound's reverbsc:
//  http://www.csounds.com/manual/html/reverbsc.html
//

#import "AKReverb.h"

@implementation AKReverb
{
    AKStereoAudio *aInLR;
    AKControl *kFbLvl;
    AKControl *kFCo;
}

- (instancetype)initWithSourceStereoAudio:(AKStereoAudio *)sourceStereo
                            feedbackLevel:(AKControl *)feedbackLevel
                          cutoffFrequency:(AKControl *)cutoffFrequency;

{
    self = [super initWithString:[self operationName]];
    if (self) {
        aInLR  = sourceStereo;
        kFbLvl = feedbackLevel;
        kFCo   = cutoffFrequency;
    }
    return self;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                      feedbackLevel:(AKControl *)feedbackLevel
                    cutoffFrequency:(AKControl *)cutoffFrequency;
{
    return [self initWithSourceStereoAudio:[AKStereoAudio stereoFromMono:audioSource]
                             feedbackLevel:feedbackLevel
                           cutoffFrequency:cutoffFrequency];
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ reverbsc %@, %@, %@",
            self , aInLR, kFbLvl, kFCo];
}

@end
