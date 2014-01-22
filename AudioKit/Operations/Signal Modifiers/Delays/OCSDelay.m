//
//  OCSDelay.m
//  Objective-C Sound
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/12.
//  Customization by Aurelius Prochazka on 12/28/13
//
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's delay:
//  http://www.csounds.com/manual/html/delay.html
//

#import "OCSDelay.h"

@interface OCSDelay () {
    OCSAudio *asig;
    OCSControl *kFeedback;
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
        kFeedback = ocsp(0);
    }
    return self;
}
- (void)setOptionalFeedback:(OCSControl *)feedback {
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