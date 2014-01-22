//
//  AKReverbAllpass.m
//  AudioKit
//
//  Created by Adam Boulanger on 10/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKReverbAllpass.h"

@interface AKReverbAllpass ()
{
    AKAudio *asig;
    AKControl *krvt;
    AKConstant *ilpt;
    AKConstant *iskip;
    AKConstant *insmps;
}
@end

@implementation AKReverbAllpass

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                  reverberationTime:(AKControl *)reverberationTime
                           loopTime:(AKConstant *)loopTime;
{
    return [self initWithAudioSource:audioSource
                   reverberationTime:reverberationTime
                            loopTime:loopTime
                    initialDelayTime:akpi(0)
                         delayAmount:akpi(0)];
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                  reverberationTime:(AKControl *)reverberationTime
                           loopTime:(AKConstant *)loopTime
                   initialDelayTime:(AKConstant *)initialDelayTime
                        delayAmount:(AKConstant *)delayAmount;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = audioSource;
        krvt = reverberationTime;
        ilpt = loopTime;
        iskip = initialDelayTime;
        insmps = delayAmount;
    }
    return self;
}

// Csound prototype: ares alpass asig, krvt, ilpt [, iskip] [, insmps]
- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ alpass %@, %@, %@, %@, %@",
            self, asig, krvt, ilpt, iskip, insmps];
}

@end
