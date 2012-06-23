//
//  OCSLineSegment.h
//
//  Description:
//  Trace a series of line segments between specified points.
//
//  Unlike several other linear and exponential generators OCSLineSegment 
//  holds the final value if the sum of segment durations is less than the 
//  note duration.
//  
//  Csd Representation:
//  ares linseg ia, idur1, ib [, idur2] [, ic] [...]
//  kres linseg ia, idur1, ib [, idur2] [, ic] [...]
//

//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"
#import "OCSParamConstant.h"
#import "OCSParamArray.h"

@interface OCSLineSegment : OCSOpcode {
    OCSParamControl *output;
}
@property (nonatomic, strong) OCSParamControl *output;
@property (nonatomic, strong) OCSParamConstant *firstSegmentStartValue;
@property (nonatomic, strong) OCSParamConstant *firstSegmentDuration;
@property (nonatomic, strong) OCSParamConstant *firstSegmentTargetValue;
@property (nonatomic, strong) OCSParamArray *segmentArray;

- (id)initWithFirstSegmentStartValue:(OCSParamConstant *) start
               FirstSegmentDuration:(OCSParamConstant *) dur
           FirstSegementTargetValue:(OCSParamConstant *) targ
                       SegmentArray:(OCSParamArray *)aSegmentArray;

- (id)initWithFirstSegmentStartValue:(OCSParamConstant *) start
               FirstSegmentDuration:(OCSParamConstant *) dur
           FirstSegementTargetValue:(OCSParamConstant *) targ;

@end
