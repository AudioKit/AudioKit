//
//  CSDLineSegment.h
//
//  Description:
//  Trace a series of line segments between specified points.
//
//  Unlike several other linear and exponential generators CSDLineSegment 
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

#import "CSDOpcode.h"
#import "CSDParamConstant.h"
#import "CSDParamArray.h"

@interface CSDLineSegment : CSDOpcode {
    CSDParamControl * output;
}
@property (nonatomic, strong) CSDParamControl * output;
@property (nonatomic, strong) CSDParamConstant *firstSegmentStartValue;
@property (nonatomic, strong) CSDParamConstant *firstSegmentDuration;
@property (nonatomic, strong) CSDParamConstant *firstSegmentTargetValue;
@property (nonatomic, strong) CSDParamArray *segmentArray;

-(id)initWithFirstSegmentStartValue:(CSDParamConstant *) start
               FirstSegmentDuration:(CSDParamConstant *) dur
           FirstSegementTargetValue:(CSDParamConstant *) targ
                       SegmentArray:(CSDParamArray *)aSegmentArray;

-(id)initWithFirstSegmentStartValue:(CSDParamConstant *) start
               FirstSegmentDuration:(CSDParamConstant *) dur
           FirstSegementTargetValue:(CSDParamConstant *) targ;

@end
