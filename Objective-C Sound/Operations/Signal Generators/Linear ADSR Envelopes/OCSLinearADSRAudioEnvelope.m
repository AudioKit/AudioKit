//
//  OCSLinearADSRAudioEnvelope.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/31/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's adsr:
//  http://www.csounds.com/manual/html/adsr.html
//

#import "OCSLinearADSRAudioEnvelope.h"

@interface OCSLinearADSRAudioEnvelope () {
    OCSConstant *iatt;
    OCSConstant *idec;
    OCSConstant *islev;
    OCSConstant *irel;
    OCSConstant *idel;
}
@end

@implementation OCSLinearADSRAudioEnvelope

- (instancetype)initWithAttackDuration:(OCSConstant *)attackDuration
               decayDuration:(OCSConstant *)decayDuration
                sustainLevel:(OCSConstant *)sustainLevel
             releaseDuration:(OCSConstant *)releaseDuration
{
    self = [super initWithString:[self operationName]];
    if (self) {
        iatt = attackDuration;
        idec = decayDuration;
        islev = sustainLevel;
        irel = releaseDuration;
        idel = ocsp(0);
    }
    return self;
}

- (void)setOptionalDelay:(OCSConstant *)delay {
	idel = delay;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ adsr %@, %@, %@, %@, %@",
            self, iatt, idec, islev, irel, idel];
}

@end