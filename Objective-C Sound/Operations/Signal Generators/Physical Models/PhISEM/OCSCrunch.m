//
//  OCSCrunch.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's crunch:
//  http://www.csounds.com/manual/html/crunch.html
//

#import "OCSCrunch.h"

@interface OCSCrunch () {
    OCSConstant *idettack;
    OCSConstant *iamp;
    OCSConstant *inum;
    OCSConstant *idamp;
    OCSConstant *imaxshake;
}
@end

@implementation OCSCrunch

- (instancetype)initWithDuration:(OCSConstant *)duration
             amplitude:(OCSConstant *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        idettack = duration;
        iamp = amplitude;
        
        inum = ocsp(7);
        idamp = ocsp(0.03);
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
            @"%@ crunch %@, %@, %@, %@, %@",
            self, iamp, idettack, inum, idamp, imaxshake];
}

@end