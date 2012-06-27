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
 
 http://www.csounds.com/manual/html/linseg.html
 */

@interface OCSLineSegment : OCSOpcode 

/// The output is either a control or an audio signal.
@property (nonatomic, strong) OCSParamControl *output;

/// Creates a series of linear segments between specicified points.
/// @param firstSegmentStartValue  Starting value. 
/// @param firstSegmentTargetValue Value after duration seconds.  
/// @param firstSegmentDuration    Duration in seconds of first segment. A zero or negative value will cause all initialization to be skipped.
/// @param durationValuePairs      Array in the form "duration, value, duration, value" etc.
- (id)initWithFirstSegmentStartValue:(OCSParamConstant *)firstSegmentStartValue
             FirstSegmentTargetValue:(OCSParamConstant *)firstSegmentTargetValue
                FirstSegmentDuration:(OCSParamConstant *)firstSegmentDuration
                  DurationValuePairs:(OCSParamArray *)durationValuePairs;

/// Creates a single linear segment.
/// @param firstSegmentStartValue  Starting value. 
/// @param firstSegmentTargetValue Value after duration seconds. 
/// @param firstSegmentDuration    Duration in seconds of first segment. A zero or negative value will cause all initialization to be skipped.
- (id)initWithFirstSegmentStartValue:(OCSParamConstant *)firstSegmentStartValue
             FirstSegmentTargetValue:(OCSParamConstant *)firstSegmentTargetValue
                FirstSegmentDuration:(OCSParamConstant *)firstSegmentDuration;

@end
