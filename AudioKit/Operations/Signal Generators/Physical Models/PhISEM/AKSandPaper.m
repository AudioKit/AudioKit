//
//  AKSandPaper.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's sandpaper:
//  http://www.csounds.com/manual/html/sandpaper.html
//

#import "AKSandPaper.h"

@interface AKSandPaper () {
    AKConstant *idettack;
    AKConstant *iamp;
    AKConstant *inum;
    AKConstant *idamp;
    AKConstant *imaxshake;
}
@end

@implementation AKSandPaper

- (instancetype)initWithDuration:(AKConstant *)duration
                       amplitude:(AKConstant *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        idettack = duration;
        iamp = amplitude;
        inum = akp(128);
        idamp = akp(0.5);
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
            @"%@ sandpaper %@, %@, %@, %@, %@",
            self, iamp, idettack, inum, idamp, imaxshake];
}

@end