//
//  OCSVariableDelay.m
//  Objective-C Sound
//
//  Auto-generated from database on 12/26/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's vdelay3:
//  http://www.csounds.com/manual/html/vdelay3.html
//

#import "OCSVariableDelay.h"

@interface OCSVariableDelay () {
    OCSAudio *asig;
    OCSAudio *adel;
    OCSConstant *imaxdel;
}
@end

@implementation OCSVariableDelay

- (instancetype)initWithAudioSource:(OCSAudio *)audioSource
                delayTime:(OCSAudio *)delayTime
         maximumDelayTime:(OCSConstant *)maximumDelayTime
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