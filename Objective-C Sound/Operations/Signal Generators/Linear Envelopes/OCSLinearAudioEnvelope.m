//
//  OCSLinearAudioEnvelope.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 5/17/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSLinearAudioEnvelope.h"

@interface OCSLinearAudioEnvelope () {
    OCSParameter *amp;
    OCSConstant *rise;
    OCSConstant *dur;
    OCSConstant *decay;    
}

@end

@implementation OCSLinearAudioEnvelope

- (instancetype)initWithRiseTime:(OCSConstant *)riseTime
         totalDuration:(OCSConstant *)totalDuration
             decayTime:(OCSConstant *)decayTime
             amplitude:(OCSParameter *)amplitude
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
