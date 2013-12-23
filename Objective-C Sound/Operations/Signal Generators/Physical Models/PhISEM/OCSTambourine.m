//
//  OCSTambourine.m
//  Objective-C Sound
//
//  Auto-generated from database on 11/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's tambourine:
//  http://www.csounds.com/manual/html/tambourine.html
//

#import "OCSTambourine.h"

@interface OCSTambourine () {
    OCSConstant *idettack;
    OCSControl *kamp;
    OCSConstant *inum;
    OCSConstant *idamp;
    OCSConstant *imaxshake;
    OCSConstant *ifreq;
    OCSConstant *ifreq1;
    OCSConstant *ifreq2;
}
@end

@implementation OCSTambourine

- (instancetype)initWithMaximumDuration:(OCSConstant *)maximumDuration
                              amplitude:(OCSControl *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        idettack = maximumDuration;
        kamp = amplitude;
        inum = ocsp(32);
        idamp = ocsp(0);
        imaxshake = ocsp(0);
        ifreq = ocsp(2300);
        ifreq1 = ocsp(5600);
        ifreq2 = ocsp(8100);
    }
    return self;
}

- (void)setOptionalCount:(OCSConstant *)count {
	inum = count;
}

- (void)setOptionalDampingFactor:(OCSConstant *)dampingFactor {
	idamp = dampingFactor;
}

- (void)setOptionalEnergyReturn:(OCSConstant *)energyReturn {
	imaxshake = energyReturn;
}

- (void)setOptionalMainResonantFrequency:(OCSConstant *)mainResonantFrequency {
	ifreq = mainResonantFrequency;
}

- (void)setOptionalFirstResonantFrequency:(OCSConstant *)firstResonantFrequency {
	ifreq1 = firstResonantFrequency;
}

- (void)setOptionalSecondResonantFrequency:(OCSConstant *)secondResonantFrequency {
	ifreq2 = secondResonantFrequency;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ tambourine %@, %@, %@, %@, %@, %@, %@, %@",
            self, kamp, idettack, inum, idamp, imaxshake, ifreq, ifreq1, ifreq2];
}

@end