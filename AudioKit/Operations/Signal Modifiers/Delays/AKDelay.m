//
//  AKDelay.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/12.
//  Customization by Aurelius Prochazka on 12/28/13
//
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's delay:
//  http://www.csounds.com/manual/html/delay.html
//

#import "AKDelay.h"

@implementation AKDelay
{
    AKAudio *asig;
    AKControl *kFeedback;
    AKConstant *idlt;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                          delayTime:(AKConstant *)delayTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = audioSource;
        idlt = delayTime;
        kFeedback = akp(0);
    }
    return self;
}
- (void)setOptionalFeedback:(AKControl *)feedback {
    kFeedback = feedback;
}

- (NSString *)stringForCSD {
    NSString *initialization = [NSString stringWithFormat:@"%@ init 0", self];
    
    NSString *opcodeLine = [NSString stringWithFormat:
                            @"%@ delay %@ + (%@*%@), %@",
                            self, asig, self, kFeedback, idlt];
    return [NSString stringWithFormat:@"%@\n%@", initialization, opcodeLine];
}

@end