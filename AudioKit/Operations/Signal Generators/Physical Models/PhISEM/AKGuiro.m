//
//  AKGuiro.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/4/12.
//  Manually modified by Aurelius Prochazka on 11/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's guiro:
//  http://www.csounds.com/manual/html/guiro.html
//

#import "AKGuiro.h"

@interface AKGuiro () {
    AKConstant *idettack;
    AKControl *kamp;
    AKConstant *inum;
    AKConstant *imaxshake;
    AKConstant *ifreq;
    AKConstant *ifreq1;
}
@end

@implementation AKGuiro

- (instancetype)initWithDuration:(AKConstant *)duration
                       amplitude:(AKControl *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        idettack = duration;
        kamp = amplitude;
        
        inum = akp(128);
        imaxshake = akp(0);
        ifreq = akp(2500);
        ifreq1 = akp(4000);
    }
    return self;
}


- (void)setOptionalCount:(AKConstant *)count {
	inum = count;
}

- (void)setOptionalEnergyReturn:(AKConstant *)energyReturn {
	imaxshake = energyReturn;
}

- (void)setOptionalMainResonantFrequency:(AKConstant *)mainResonantFrequency {
	ifreq = mainResonantFrequency;
}

- (void)setOptionalFirstResonantFrequency:(AKConstant *)firstResonantFrequency {
	ifreq = firstResonantFrequency;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ guiro %@, %@, %@, 0, %@, %@, %@",
            self, kamp, idettack, inum, imaxshake, ifreq, ifreq1];
}

@end