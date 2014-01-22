//
//  OCSStick.m
//  Objective-C Sound
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's stix:
//  http://www.csounds.com/manual/html/stix.html
//

#import "OCSStick.h"

@interface OCSStick () {
    OCSConstant *idettack;
    OCSConstant *iamp;
    OCSConstant *inum;
    OCSConstant *idamp;
    OCSConstant *imaxshake;
}
@end

@implementation OCSStick

- (instancetype)initWithMaximumDuration:(OCSConstant *)maximumDuration
                              amplitude:(OCSConstant *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        idettack = maximumDuration;
        iamp = amplitude;
        inum = ocsp(30);
        idamp = ocsp(0);
        imaxshake = ocsp(0);
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

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ stix %@, %@, %@, %@, %@",
            self, iamp, idettack, inum, idamp, imaxshake];
}

@end