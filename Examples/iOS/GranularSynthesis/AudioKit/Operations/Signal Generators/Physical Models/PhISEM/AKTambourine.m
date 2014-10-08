//
//  AKTambourine.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's tambourine:
//  http://www.csounds.com/manual/html/tambourine.html
//

#import "AKTambourine.h"

@interface AKTambourine () {
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

@implementation AKTambourine

- (instancetype)initWithMaximumDuration:(AKConstant *)maximumDuration
                              amplitude:(AKControl *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        idettack = maximumDuration;
        kamp = amplitude;
        inum = akp(32);
        idamp = akp(0);
        imaxshake = akp(0);
        ifreq = akp(2300);
        ifreq1 = akp(5600);
        ifreq2 = akp(8100);
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
            @"%@ tambourine %@, %@, %@, %@, %@, %@, %@, %@",
            self, kamp, idettack, inum, idamp, imaxshake, ifreq, ifreq1, ifreq2];
}

@end