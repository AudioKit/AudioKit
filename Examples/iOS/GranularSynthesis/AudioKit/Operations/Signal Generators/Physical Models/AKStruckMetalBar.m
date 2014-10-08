//
//  AKStruckMetalBar.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's barmodel:
//  http://www.csounds.com/manual/html/barmodel.html
//

#import "AKStruckMetalBar.h"

@implementation AKStruckMetalBar
{
    AKConstant *iT30;
    AKConstant *iK;
    AKConstant *ib;
    AKConstant *ipos;
    AKConstant *ivel;
    AKConstant *iwid;
    AKControl *kbcL;
    AKControl *kbcR;
    AKControl *kscan;
}

- (instancetype)initWithDecayTime:(AKConstant *)decayTime
           dimensionlessStiffness:(AKConstant *)dimensionlessStiffness
                highFrequencyLoss:(AKConstant *)highFrequencyLoss
                   strikePosition:(AKConstant *)strikePosition
                   strikeVelocity:(AKConstant *)strikeVelocity
                      strikeWidth:(AKConstant *)strikeWidth
            leftBoundaryCondition:(AKControl *)leftBoundaryCondition
           rightBoundaryCondition:(AKControl *)rightBoundaryCondition
                        scanSpeed:(AKControl *)scanSpeed
{
    self = [super initWithString:[self operationName]];
    if (self) {
        iT30 = decayTime;
        iK = dimensionlessStiffness;
        ib = highFrequencyLoss;
        ipos = strikePosition;
        ivel = strikeVelocity;
        iwid = strikeWidth;
        kbcL = leftBoundaryCondition;
        kbcR = rightBoundaryCondition;
        kscan = scanSpeed;
        
        
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ barmodel %@, %@, %@, %@, %@, %@, %@, %@, %@",
            self, kbcL, kbcR, iK, ib, kscan, iT30, ipos, ivel, iwid];
}

@end