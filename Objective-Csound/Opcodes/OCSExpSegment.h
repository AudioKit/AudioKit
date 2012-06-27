//
//  OCSExpSegment.h
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/**
 Trace a series of exponential segments between specified points.
 
 http://www.csounds.com/manual/html/expseg.html
 */

@interface OCSExpSegment : OCSOpcode

/// The output is either a control or an audio signal.
@property (nonatomic, strong) OCSParamControl *output;

/// Creates a series of exponential segments between specicified points.
/// @param firstSegmentStartValue  Starting value. Zero is illegal for exponentials.
/// @param firstSegmentTargetValue Value after duration seconds.  For exponentials, must be non-zero and must agree in sign with starting value.
/// @param firstSegmentDuration    Duration in seconds of first segment. A zero or negative value will cause all initialization to be skipped.
/// @param durationValuePairs      Array in the form "duration, value, duration, value" etc.
- (id)initWithFirstSegmentStartValue:(OCSParamConstant *)firstSegmentStartValue
             FirstSegmentTargetValue:(OCSParamConstant *)firstSegmentTargetValue
                FirstSegmentDuration:(OCSParamConstant *)firstSegmentDuration
                  DurationValuePairs:(OCSParamArray *)durationValuePairs;

/// Creates a single exponential segment.
/// @param firstSegmentStartValue  Starting value. Zero is illegal for exponentials.
/// @param firstSegmentTargetValue Value after duration seconds.  For exponentials, must be non-zero and must agree in sign with starting value.
/// @param firstSegmentDuration    Duration in seconds of first segment. A zero or negative value will cause all initialization to be skipped.
- (id)initWithFirstSegmentStartValue:(OCSParamConstant *)firstSegmentStartValue
             FirstSegmentTargetValue:(OCSParamConstant *)firstSegmentTargetValue
                FirstSegmentDuration:(OCSParamConstant *)firstSegmentDuration;

@end
