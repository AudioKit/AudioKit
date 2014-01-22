//
//  OCSLinearControlEnvelope.m
//  City Sounds
//
//  Created by Aurelius Prochazka on 10/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSLinearControlEnvelope.h"

@interface OCSLinearControlEnvelope () {
    OCSControl *amp;
    OCSConstant *rise;
    OCSConstant *dur;
    OCSConstant *decay;
}
@end

@implementation OCSLinearControlEnvelope

- (instancetype)initWithRiseTime:(OCSConstant *)riseTime
                   totalDuration:(OCSConstant *)totalDuration
                       decayTime:(OCSConstant *)decayTime
                       amplitude:(OCSControl  *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        amp     = amplitude;
        rise    = riseTime;
        dur     = totalDuration;
        decay   = decayTime;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ linen %@, %@, %@, %@",
            self, amp, rise, dur, decay];
}

@end
