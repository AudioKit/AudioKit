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
    OCSParameter *aOutL;
    OCSParameter *aOutR;
    OCSParameter *aInL;
    OCSParameter *aInR;
    OCSControl *kFbLvl;
    OCSControl *kFCo;
}
@end

@implementation OCSReverb

@synthesize leftOutput=aOutL;
@synthesize rightOutput=aOutR;

- (id)initWithLeftInput:(OCSParameter *)leftInput
             rightInput:(OCSParameter *)rightInput
          feedbackLevel:(OCSControl *)feedbackLevel
        cutoffFrequency:(OCSControl *)cutoffFrequency;
{
    self = [super init];
    if (self) {
        aOutL  = [OCSParameter parameterWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"L"]];
        aOutR  = [OCSParameter parameterWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"R"]];
        aInL   = leftInput;
        aInR   = rightInput;
        kFbLvl = feedbackLevel;
        kFCo   = cutoffFrequency;
    }
    return self; 
}

- (id)initWithMonoInput:(OCSParameter *)monoInput
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
