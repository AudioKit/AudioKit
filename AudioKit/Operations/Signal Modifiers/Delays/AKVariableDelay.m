//
//  AKVariableDelay.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's vdelay3:
//  http://www.csounds.com/manual/html/vdelay3.html
//

#import "AKVariableDelay.h"

@implementation AKVariableDelay
{
    AKAudio *asig;
    AKAudio *adel;
    AKConstant *imaxdel;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                          delayTime:(AKAudio *)delayTime
                   maximumDelayTime:(AKConstant *)maximumDelayTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = audioSource;
        adel = delayTime;
        imaxdel = maximumDelayTime;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ vdelay3 %@, %@, %@",
            self, asig, adel, imaxdel];
}

@end