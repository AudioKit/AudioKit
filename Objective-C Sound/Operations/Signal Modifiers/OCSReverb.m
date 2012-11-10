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

- (id)initWithSourceStereoAudio:(OCSStereoAudio *)sourceStereo
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

- (id)initWithSourceAudio:(OCSAudio *)sourceAudio
            feedbackLevel:(OCSControl *)feedbackLevel
          cutoffFrequency:(OCSControl *)cutoffFrequency;
{
    return [self initWithSourceStereoAudio:[OCSStereoAudio stereoFromMono:sourceAudio]
                             feedbackLevel:feedbackLevel
                           cutoffFrequency:cutoffFrequency];
}

// Csound prototype: aoutL, aoutR reverbsc ainL, ainR, kfblvl, kfco[, israte[, ipitchm[, iskip]]] 
- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ reverbsc %@, %@, %@",
            self , aInLR, kFbLvl, kFCo];
}

@end
