//
//  AKCombFilter.m
//  AudioKit
//
//  Created by Adam Boulanger on 4/10/13.
//  Copyright (c) 2013 Hear For Yourself. All rights reserved.
//

#import "AKCombFilter.h"

@interface AKCombFilter () {
    AKAudio *asig;
    AKControl *krvt;
    AKConstant *iskip;
    AKConstant *ilpt;
    AKConstant *insmps;
}
@end

@implementation AKCombFilter

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                         reverbTime:(AKControl *)reverbTime
                           loopTime:(AKConstant *)loopTime
{
    self = [super initWithString:[self operationName]];
    if(self) {
        asig = audioSource;
        krvt = reverbTime;
        ilpt = loopTime;
        iskip = akp(0);
        insmps = akp(0);
    }
    return self;
    
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                         reverbTime:(AKControl *)reverbTime
                           loopTime:(AKConstant *)loopTime
                        delayAmount:(AKConstant *)delayAmount
                 isFeedbackRetained:(BOOL)isFeedbackRetained
{
    self = [super initWithString:[self operationName]];
    if(self) {
        asig = audioSource;
        krvt = reverbTime;
        ilpt = loopTime;
        iskip = akp( isFeedbackRetained);
        insmps = delayAmount;
    }
    return self;
}

- (void)setOptionalDelayAmount:(AKConstant *)delayAmount
{
    insmps = delayAmount;
}

- (void)setOptionalRetainFeedbackFlag:(BOOL)isFeedbackRetained
{
    iskip = akp( isFeedbackRetained);
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ comb %@, %@, %@, %@, %@",
            self, asig, krvt, ilpt, iskip, insmps];
}

@end
