//
//  AKCrunch.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's crunch:
//  http://www.csounds.com/manual/html/crunch.html
//

#import "AKCrunch.h"

@interface AKCrunch () {
    AKConstant *idettack;
    AKConstant *iamp;
    AKConstant *inum;
    AKConstant *idamp;
    AKConstant *imaxshake;
}
@end

@implementation AKCrunch

- (instancetype)initWithDuration:(AKConstant *)duration
                       amplitude:(AKConstant *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        idettack = duration;
        iamp = amplitude;
        
        inum = akp(7);
        idamp = akp(0.03);
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
            @"%@ crunch %@, %@, %@, %@, %@",
            self, iamp, idettack, inum, idamp, imaxshake];
}

@end