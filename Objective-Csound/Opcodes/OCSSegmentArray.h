//
//  OCSSegmentArray.h
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

@interface OCSSegmentArray : OCSOpcode 

/// This is the audio signal.
@property (nonatomic, strong) OCSParam *audio;

/// This is the control parameter.
@property (nonatomic, strong) OCSParamControl *control;

/// The output is the audio signal or the control.
@property (nonatomic, strong) OCSParam *output;

/// Creates a single linear segment.
/// @param firstSegmentStartValue  Starting value. 
/// @param firstSegmentTargetValue Value after firstSegmentDuration seconds. 
/// @param firstSegmentDuration    Duration in seconds of first segment. A zero or negative value will cause all initialization to be skipped.
- (id)initWithFirstSegmentStartValue:(OCSParamConstant *)firstSegmentStartValue
             FirstSegmentTargetValue:(OCSParamConstant *)firstSegmentTargetValue
                FirstSegmentDuration:(OCSParamConstant *)firstSegmentDuration;

/// Adds another segment.
/// @param nextSegmentTargetValue Value after nextSegmentDuration seconds. 
/// @param nextSegmentDuration    Duration in seconds.
- (void)addNextSegmentTargetValue:(OCSParamConstant *)nextSegmentTargetValue 
                    AfterDuration:(OCSParamConstant *)nextSegmentDuration;


/// Adds a release segment.
/// @param finalValue      Last value to reach, typically zero.
/// @param releaseDuration Length of time in seconds to get to finalValue.
- (void)addReleaseToFinalValue:(OCSParamConstant *)finalValue 
                 AfterDuration:(OCSParamConstant *)releaseDuration;

/// Switches to an exponential segment generating opcode.
- (void)useExponentialSegments;


@end
