//
//  AKCombFilter.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/13/14
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKCombFilter.h"

@implementation AKCombFilter
{
    AKAudio *asig;
    AKControl *krvt;
    AKConstant *iskip;
    AKConstant *ilpt;
    AKConstant *insmps;
}

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
    }
    return self;
    
}

- (void)setOptionalRetainFeedbackFlag:(BOOL)isFeedbackRetained
{
    iskip = akp(isFeedbackRetained);
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ comb %@, %@, %@, %@",
            self, asig, krvt, ilpt, iskip];
}

@end
