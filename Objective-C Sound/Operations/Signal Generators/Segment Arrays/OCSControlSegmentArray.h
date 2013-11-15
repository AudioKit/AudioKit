//
//  OCSControlSegmentArray.h
//  Objective-C Sound
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParameter+Operation.h"

/**
 Trace a series of line segments between specified points. The transition
 between these points can either be linear, by default, or exponential,
 by sending invoking the useExponentialSegments method.

 */

@interface OCSControlSegmentArray : OCSControl

/// Creates the OCSSegmentArray and populates it with the minimum information.
/// Use addValue:afterDuration to add more segments to the array.
/// An optional release segment can be added with addReleaseToFinalValue:afterDuration.
/// @param firstSegmentStartValue  Starting value. 
/// @param firstSegmentTargetValue Value after firstSegmentDuration seconds. 
/// @param firstSegmentDuration    Duration in seconds of first segment. A zero or negative value will cause all initialization to be skipped.
/// @return An OCSSegment with the first segment specified.
- (instancetype)initWithStartValue:(OCSConstant *)firstSegmentStartValue
             toNextValue:(OCSConstant *)firstSegmentTargetValue
           afterDuration:(OCSConstant *)firstSegmentDuration;

/// Adds another segment.
/// @param nextSegmentTargetValue Value after nextSegmentDuration seconds. 
/// @param nextSegmentDuration    Duration in seconds.
- (void)addValue:(OCSConstant *)nextSegmentTargetValue 
   afterDuration:(OCSConstant *)nextSegmentDuration;

/// @name Optional Assignments

/// Adds a release segment.
/// @param finalValue      Last value to reach, typically zero.
/// @param releaseDuration Length of time in seconds to get to finalValue.
- (void)addReleaseToFinalValue:(OCSConstant *)finalValue 
                 afterDuration:(OCSConstant *)releaseDuration;

/// Switches to an exponential segment generating opcode.
- (void)useExponentialSegments;


@end
