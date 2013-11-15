//
//  OCSSekere.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's sekere:
//  http://www.csounds.com/manual/html/sekere.html
//

#import "OCSSekere.h"

@interface OCSSekere () {
    OCSConstant *idettack;
    OCSConstant *iamp;
    OCSConstant *inum;
    OCSConstant *idamp;
    OCSConstant *imaxshake;
}
@end

@implementation OCSSekere

- (instancetype)initWithDuration:(OCSConstant *)duration
             amplitude:(OCSConstant *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        idettack = duration;
        iamp = amplitude;
        inum = ocsp(64);
        idamp = ocsp(0.5);
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
            @"%@ sekere %@, %@, %@, %@, %@",
            self, iamp, idettack, inum, idamp, imaxshake];
}

@end