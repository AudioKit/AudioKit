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
    OCSAudio *aOutL;
    OCSAudio *aOutR;
    OCSAudio *aInL;
    OCSAudio *aInR;
    OCSControl *kFbLvl;
    OCSControl *kFCo;
}
@end

@implementation OCSReverb

@synthesize leftOutput=aOutL;
@synthesize rightOutput=aOutR;

- (id)initWithLeftInput:(OCSAudio *)leftInput
             rightInput:(OCSAudio *)rightInput
          feedbackLevel:(OCSControl *)feedbackLevel
        cutoffFrequency:(OCSControl *)cutoffFrequency;
{
    self = [super init];
    if (self) {
        aOutL  = [OCSAudio parameterWithString:[NSString stringWithFormat:@"%@%@",[self operationName], @"L"]];
        aOutR  = [OCSAudio parameterWithString:[NSString stringWithFormat:@"%@%@",[self operationName], @"R"]];
        aInL   = leftInput;
        aInR   = rightInput;
        kFbLvl = feedbackLevel;
        kFCo   = cutoffFrequency;
    }
    return self; 
}

- (id)initWithMonoInput:(OCSAudio *)monoInput
          feedbackLevel:(OCSControl *)feedbackLevel
        cutoffFrequency:(OCSControl *)cutoffFrequency;
{
    return [self initWithLeftInput:monoInput 
                        rightInput:monoInput
                     feedbackLevel:feedbackLevel
                   cutoffFrequency:cutoffFrequency];
}

// Csound prototype: aoutL, aoutR reverbsc ainL, ainR, kfblvl, kfco[, israte[, ipitchm[, iskip]]] 
- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@, %@ reverbsc %@, %@, %@, %@",
            aOutL, aOutR, aInL, aInR, kFbLvl, kFCo];
}

@end
