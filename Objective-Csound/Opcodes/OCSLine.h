//
//  OCSLine.h
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"
#import "OCSParamConstant.h"

/**
 Trace a straight line between specified points
 
 Unlike several other linear and exponential generators OCSLine 
 does not hold the final value of "ib" if "idur" is shorter than the 
 not duration.  Rather, it will continue ramping at the previously calculated
 rate until the note ends.
 
 CSD Representation:
 
    ares line ia, idur, ib
    kres line ia, idur, ib
 */

@interface OCSLine : OCSOpcode

@property (nonatomic, strong) OCSParamControl  *output;
@property (nonatomic, strong) OCSParamConstant *startingValue;
@property (nonatomic, strong) OCSParamConstant *duration;
@property (nonatomic, strong) OCSParamConstant *targetValue;

/// Initialization Statement
- (id)initWithStartingValue:(OCSParamConstant *) start
                  Duration:(OCSParamConstant *) dur
               TargetValue:(OCSParamConstant *) targ;
    

@end
