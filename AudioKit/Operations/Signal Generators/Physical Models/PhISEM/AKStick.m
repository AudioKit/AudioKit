//
//  AKStick.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's stix:
//  http://www.csounds.com/manual/html/stix.html
//

#import "AKStick.h"

@interface AKStick () {
    AKConstant *idettack;
    AKConstant *iamp;
    AKConstant *inum;
    AKConstant *idamp;
    AKConstant *imaxshake;
}
@end

@implementation AKStick

- (instancetype)initWithMaximumDuration:(AKConstant *)maximumDuration
                              amplitude:(AKConstant *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        idettack = maximumDuration;
        iamp = amplitude;
        inum = akp(30);
        idamp = akp(0);
        imaxshake = akp(0);
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

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ stix %@, %@, %@, %@, %@",
            self, iamp, idettack, inum, idamp, imaxshake];
}

@end