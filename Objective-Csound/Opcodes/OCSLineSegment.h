//
//  OCSLineSegment.h
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/**
 Trace a series of line segments between specified points.
 
 Unlike several other linear and exponential generators OCSLineSegment 
 holds the final value if the sum of segment durations is less than the 
 note duration.
 
 CSD Representation:
 
    ares linseg ia, idur1, ib...
    kres linseg ia, idur1, ib...
 */

@interface OCSLineSegment : OCSOpcode 

@property (nonatomic, strong) OCSParamControl *output;
@property (nonatomic, strong) OCSParamConstant *firstSegmentStartValue;
@property (nonatomic, strong) OCSParamConstant *firstSegmentDuration;
@property (nonatomic, strong) OCSParamConstant *firstSegmentTargetValue;
@property (nonatomic, strong) OCSParamArray *segmentArray;

/// Initialization Statement
- (id)initWithFirstSegmentStartValue:(OCSParamConstant *)start
               FirstSegmentDuration:(OCSParamConstant *)dur
           FirstSegementTargetValue:(OCSParamConstant *)targ
                       SegmentArray:(OCSParamArray *)aSegmentArray;

/// Initialization Statement
- (id)initWithFirstSegmentStartValue:(OCSParamConstant *)start
               FirstSegmentDuration:(OCSParamConstant *)dur
           FirstSegementTargetValue:(OCSParamConstant *)targ;

@end
