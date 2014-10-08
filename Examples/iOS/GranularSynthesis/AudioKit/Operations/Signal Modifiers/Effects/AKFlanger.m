//
//  AKFlanger.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's flanger:
//  http://www.csounds.com/manual/html/flanger.html
//

#import "AKFlanger.h"

@implementation AKFlanger
{
    AKAudio *asig;
    AKAudio *adel;
    AKControl *kfeedback;
}

- (instancetype)initWithSourceSignal:(AKAudio *)sourceSignal
                           delayTime:(AKAudio *)delayTime
                            feedback:(AKControl *)feedback
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