//
//  OCSCombFilter.m
//  Objective-C Sound
//
//  Created by Adam Boulanger on 4/10/13.
//  Copyright (c) 2013 Hear For Yourself. All rights reserved.
//

#import "OCSCombFilter.h"

@interface OCSCombFilter () {
    OCSAudio *asig;
    OCSControl *krvt;
    OCSConstant *iskip;
    OCSConstant *ilpt;
    OCSConstant *insmps;
}
@end

@implementation OCSCombFilter

-(instancetype)initWithAudioSource:(OCSAudio *)audioSource
                        reverbTime:(OCSControl *)reverbTime
                          loopTime:(OCSConstant *)loopTime
{
    self = [super initWithString:[self operationName]];
    if(self) {
        asig = audioSource;
        krvt = reverbTime;
        ilpt = loopTime;
        iskip = ocsp(0);
        insmps = ocsp(0);
    }
    return self;
    
}

-(instancetype)initWithAudioSource:(OCSAudio *)audioSource
                        reverbTime:(OCSControl *)reverbTime
                          loopTime:(OCSConstant *)loopTime
                       delayAmount:(OCSConstant *)delayAmount
                isFeedbackRetained:(BOOL)isFeedbackRetained
{
    self = [super initWithString:[self operationName]];
    if(self) {
        asig = audioSource;
        krvt = reverbTime;
        ilpt = loopTime;
        iskip = ocsp( isFeedbackRetained);
        insmps = delayAmount;
    }
    return self;
}

-(void)setOptionalDelayAmount:(OCSConstant *)delayAmount
{
    insmps = delayAmount;
}

-(void)setOptionalRetainFeedbackFlag:(BOOL)isFeedbackRetained
{
    iskip = ocsp( isFeedbackRetained);
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ comb %@, %@, %@, %@, %@",
            self, asig, krvt, ilpt, iskip, insmps];
}

@end
