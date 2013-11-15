//
//  OCSFlanger.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's flanger:
//  http://www.csounds.com/manual/html/flanger.html
//

#import "OCSFlanger.h"

@interface OCSFlanger () {
    OCSAudio *asig;
    OCSAudio *adel;
    OCSControl *kfeedback;
}
@end

@implementation OCSFlanger

- (instancetype)initWithSourceSignal:(OCSAudio *)sourceSignal
                 delayTime:(OCSAudio *)delayTime
                  feedback:(OCSControl *)feedback
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = sourceSignal;
        adel = delayTime;
        kfeedback = feedback;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ flanger %@, %@, %@",
            self, asig, adel, kfeedback];
}

@end