//
//  AKLinearADSRAudioEnvelope.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/31/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's adsr:
//  http://www.csounds.com/manual/html/adsr.html
//

#import "AKLinearADSRAudioEnvelope.h"

@implementation AKLinearADSRAudioEnvelope
{
    AKConstant *iatt;
    AKConstant *idec;
    AKConstant *islev;
    AKConstant *irel;
    AKConstant *idel;
}

- (instancetype)initWithAttackDuration:(AKConstant *)attackDuration
                         decayDuration:(AKConstant *)decayDuration
                          sustainLevel:(AKConstant *)sustainLevel
                       releaseDuration:(AKConstant *)releaseDuration
{
    self = [super initWithString:[self operationName]];
    if (self) {
        iatt = attackDuration;
        idec = decayDuration;
        islev = sustainLevel;
        irel = releaseDuration;
        idel = akp(0);
    }
    return self;
}

- (void)setOptionalDelay:(AKConstant *)delay {
	idel = delay;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ adsr %@, %@, %@, %@, %@",
            self, iatt, idec, islev, irel, idel];
}

@end