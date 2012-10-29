//
//  OCSStruckMetalBar.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's barmodel:
//  http://www.csounds.com/manual/html/barmodel.html
//

#import "OCSStruckMetalBar.h"

@interface OCSStruckMetalBar () {
    OCSConstant *iT30;
    OCSConstant *iK;
    OCSConstant *ib;
    OCSConstant *ipos;
    OCSConstant *ivel;
    OCSConstant *iwid;
    OCSControl *kbcL;
    OCSControl *kbcR;
    OCSControl *kscan;
}
@end

@implementation OCSStruckMetalBar

- (id)initWithDecayTime:(OCSConstant *)decayTime
 dimensionlessStiffness:(OCSConstant *)dimensionlessStiffness
      highFrequencyLoss:(OCSConstant *)highFrequencyLoss
         strikePosition:(OCSConstant *)strikePosition
         strikeVelocity:(OCSConstant *)strikeVelocity
            strikeWidth:(OCSConstant *)strikeWidth
  leftBoundaryCondition:(OCSControl *)leftBoundaryCondition
 rightBoundaryCondition:(OCSControl *)rightBoundaryCondition
              scanSpeed:(OCSControl *)scanSpeed
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
            self, kbcL, kbcR, iK, ib, kscan, iT30, ipos, ivel, iwid, iwid];
}

@end