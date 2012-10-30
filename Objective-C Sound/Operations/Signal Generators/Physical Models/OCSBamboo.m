//
//  OCSBamboo.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's bamboo:
//  http://www.csounds.com/manual/html/bamboo.html
//

#import "OCSBamboo.h"

@interface OCSBamboo () {
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

@implementation OCSBamboo

- (id)initWithDuration:(OCSConstant *)duration
             amplitude:(OCSControl *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        idettack = duration;
        kamp = amplitude;
        
        inum = ocsp(1.25);
        idamp = ocsp(0);
        imaxshake = ocsp(0);
        ifreq  = ocsp(2800);
        ifreq1 = ocsp(2240);
        ifreq2 = ocsp(3360);
        
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
            @"%@ bamboo %@, %@, %@, %@, %@, %@, %@, %@",
            self, kamp, idettack, inum, idamp, imaxshake, ifreq, ifreq1, ifreq2];
}

@end