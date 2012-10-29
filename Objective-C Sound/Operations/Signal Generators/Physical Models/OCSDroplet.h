//
//  OCSDroplet.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's dripwater:
//  http://www.csounds.com/manual/html/dripwater.html
//

#import "OCSDroplet.h"

@interface OCSDroplet () {
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

@implementation OCSDroplet

- (id)initWithDuration:(OCSConstant *)duration
             amplitude:(OCSControl *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        idettack = duration;
        kamp = amplitude;
        
        inum = DEFAULT_VALUE;
        idamp = DEFAULT_VALUE;
        imaxshake = DEFAULT_VALUE;
        ifreq = DEFAULT_VALUE;
        ifreq1 = DEFAULT_VALUE;
        ifreq2 = DEFAULT_VALUE;
        
        
    }
    return self;
}


- (void)setCount:(OCSConstant *)count {
	inum = count;
}

- (void)setDampingFactor:(OCSConstant *)dampingFactor {
	idamp = dampingFactor;
}

- (void)setEnergyReturn:(OCSConstant *)energyReturn {
	imaxshake = energyReturn;
}

- (void)setMainResonantFrequency:(OCSConstant *)mainResonantFrequency {
	ifreq = mainResonantFrequency;
}

- (void)setFirstResonantFrequency:(OCSConstant *)firstResonantFrequency {
	ifreq1 = firstResonantFrequency;
}

- (void)setSecondResonantFrequency:(OCSConstant *)secondResonantFrequency {
	ifreq2 = secondResonantFrequency;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ dripwater %@, %@, %@, %@, %@, %@, %@, %@",
            self, kamp, idettack, inum, idamp, imaxshake, ifreq, ifreq1, ifreq2];
}

@end