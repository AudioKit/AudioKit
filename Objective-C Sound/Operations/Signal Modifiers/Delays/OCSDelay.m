//
//  OCSDelay.m
//  Objective-C Sound
//
//  Auto-generated from database on 12/26/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's delay:
//  http://www.csounds.com/manual/html/delay.html
//

#import "OCSDelay.h"

@interface OCSDelay () {
    OCSAudio *asig;
    OCSConstant *idlt;
}
@end

@implementation OCSDelay

- (instancetype)initWithAudioSource:(OCSAudio *)audioSource
                delayTime:(OCSConstant *)delayTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = audioSource;
        idlt = delayTime;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ delay %@, %@",
            self, asig, idlt];
}

@end