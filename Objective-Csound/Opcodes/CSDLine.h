//
//  CSDLine.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Description:
//  Trace a straight line between specified points
//
//  Unlike several other linear and exponential generators CSDLine 
//  does not hold the final value of "ib" if "idur" is shorter than the 
//  not duration.  Rather, it will continue ramping at the previously calculated
//  rate until the note ends.
//
//  Csd Representation:
//  ares line ia, idur, ib
//  kres line ia, idur, ib

#import "CSDOpcode.h"
#import "CSDParam.h"

@interface CSDLine : CSDOpcode
@property (nonatomic, strong) CSDParam *startingValue;
@property (nonatomic, strong) CSDParam *duration;
@property (nonatomic, strong) CSDParam *targetValue;

-(NSString *)convertToCsd;

-(id)initWithIStartingValue:(CSDParam *) aStart
                  iDuration:(CSDParam *) aDuration
               iTargetValue:(CSDParam *) aTarget;
    

@end
