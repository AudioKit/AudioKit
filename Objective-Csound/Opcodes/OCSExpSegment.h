//
//  OCSExpSegment.h
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/**
 Trace a series of exponential segments between specified points.
 
 CSD Representation:
 
 ares expseg ia, idur1, ib...
 kres expseg ia, idur1, ib...
 */

@interface OCSExpSegment : OCSOpcode

@property (nonatomic, strong) OCSParamControl *output;

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
