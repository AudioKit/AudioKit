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

- (id)initWithStereoInput:(OCSStereoAudio *)stereoInput
            feedbackLevel:(OCSControl *)feedbackLevel
          cutoffFrequency:(OCSControl *)cutoffFrequency;
{
    self = [super init];
    if (self) {
        aInLR  = stereoInput;
        kFbLvl = feedbackLevel;
        kFCo   = cutoffFrequency;
    }
    return self; 
}

- (id)initWithMonoInput:(OCSAudio *)monoInput
          feedbackLevel:(OCSControl *)feedbackLevel
        cutoffFrequency:(OCSControl *)cutoffFrequency;
{
    return [self initWithStereoInput:[OCSStereoAudio stereoFromMono:monoInput]
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
