//
//  AKSleighbells.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's sleighbells:
//  http://www.csounds.com/manual/html/sleighbells.html
//

#import "AKSleighbells.h"

@interface AKSleighbells () {
    AKConstant *idettack;
    AKControl *kamp;
    AKConstant *inum;
    AKConstant *idamp;
    AKConstant *imaxshake;
    AKConstant *ifreq;
    AKConstant *ifreq1;
    AKConstant *ifreq2;
}
@end

@implementation AKSleighbells

- (instancetype)initWithDuration:(AKConstant *)duration
                       amplitude:(AKControl *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        idettack = duration;
        kamp = amplitude;
        inum = akp(1.25);
        idamp = akp(0);
        imaxshake = akp(0);
        ifreq = akp(2500);
        ifreq1 = akp(5300);
        ifreq2 = akp(6500);
    }
    return self;
}

- (void)setOptionalCount:(AKConstant *)count {
	inum = count;
}

- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor {
	idamp = dampingFactor;
}

- (void)setOptionalEnergyReturn:(AKConstant *)energyReturn {
	imaxshake = energyReturn;
}

- (void)setOptionalMainResonantFrequency:(AKConstant *)mainResonantFrequency {
	ifreq = mainResonantFrequency;
}

- (void)setOptionalFirstResonantFrequency:(AKConstant *)firstResonantFrequency {
	ifreq1 = firstResonantFrequency;
}

- (void)setOptionalSecondResonantFrequency:(AKConstant *)secondResonantFrequency {
	ifreq2 = secondResonantFrequency;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ sleighbells %@, %@, %@, %@, %@, %@, %@, %@",
            self, kamp, idettack, inum, idamp, imaxshake, ifreq, ifreq1, ifreq2];
}

@end