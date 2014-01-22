//
//  OCSReverb.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  This is an incomplete port of the Csound's reverbsc:
//  http://www.csounds.com/manual/html/reverbsc.html
//

#import "OCSReverb.h"

@interface OCSReverb () {
    OCSStereoAudio *aInLR;
    OCSControl *kFbLvl;
    OCSControl *kFCo;
}
@end

@implementation OCSReverb

- (instancetype)initWithSourceStereoAudio:(OCSStereoAudio *)sourceStereo
                            feedbackLevel:(OCSControl *)feedbackLevel
                          cutoffFrequency:(OCSControl *)cutoffFrequency;

{
    self = [super init];
    if (self) {
        aInLR  = sourceStereo;
        kFbLvl = feedbackLevel;
        kFCo   = cutoffFrequency;
    }
    return self;
}

- (instancetype)initWithAudioSource:(OCSAudio *)audioSource
                      feedbackLevel:(OCSControl *)feedbackLevel
                    cutoffFrequency:(OCSControl *)cutoffFrequency;
{
    return [self initWithSourceStereoAudio:[OCSStereoAudio stereoFromMono:audioSource]
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
