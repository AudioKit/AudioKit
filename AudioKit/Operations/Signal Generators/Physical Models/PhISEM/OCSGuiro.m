//
//  OCSGuiro.m
//  Objective-C Sound
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/4/12.
//  Manually modified by Aurelius Prochazka on 11/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's guiro:
//  http://www.csounds.com/manual/html/guiro.html
//

#import "OCSGuiro.h"

@interface OCSGuiro () {
    OCSConstant *idettack;
    OCSControl *kamp;
    OCSConstant *inum;
    OCSConstant *imaxshake;
    OCSConstant *ifreq;
    OCSConstant *ifreq1;
}
@end

@implementation OCSGuiro

- (instancetype)initWithDuration:(OCSConstant *)duration
                       amplitude:(OCSControl *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        idettack = duration;
        kamp = amplitude;
        
        inum = ocsp(128);
        imaxshake = ocsp(0);
        ifreq = ocsp(2500);
        ifreq1 = ocsp(4000);
    }
    return self;
}


- (void)setOptionalCount:(OCSConstant *)count {
	inum = count;
}

- (void)setOptionalEnergyReturn:(OCSConstant *)energyReturn {
	imaxshake = energyReturn;
}

- (void)setOptionalMainResonantFrequency:(OCSConstant *)mainResonantFrequency {
	ifreq = mainResonantFrequency;
}

- (void)setOptionalFirstResonantFrequency:(OCSConstant *)firstResonantFrequency {
	ifreq = firstResonantFrequency;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ guiro %@, %@, %@, 0, %@, %@, %@",
            self, kamp, idettack, inum, imaxshake, ifreq, ifreq1];
}

@end