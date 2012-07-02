//
//  OCSSegmentArray.h
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/**
 Trace a series of line segments between specified points. The transition
 between these points can either be linear, by default, or exponential,
 by sending invoking the useExponentialSegments method.
 
 http://www.csounds.com/manual/html/linsegr.html
 
 http://www.csounds.com/manual/html/expsegr.html
 */

@interface OCSSegmentArray : OCSOpcode 

/// This is the audio signal.
@property (nonatomic, strong) OCSParam *audio;

/// This is the control parameter.
@property (nonatomic, strong) OCSControlParam *control;

/// The output is the audio signal or the control.
@property (nonatomic, strong) OCSParam *output;

/// Creates the OCSSegmentArray and populates it with the minimum information.
/// Use addValue:afterDuration to add more segments to the array.
/// An optional release segment can be added with addReleaseToFinalValue:afterDuration.
/// @param firstSegmentStartValue  Starting value. 
/// @param firstSegmentTargetValue Value after firstSegmentDuration seconds. 
/// @param firstSegmentDuration    Duration in seconds of first segment. A zero or negative value will cause all initialization to be skipped.
/// @return An OCSSegment with the first segment specified.
- (id)initWithStartValue:(OCSConstantParam *)firstSegmentStartValue
             toNextValue:(OCSConstantParam *)firstSegmentTargetValue
           afterDuration:(OCSConstantParam *)firstSegmentDuration;

/// Adds another segment.
/// @param nextSegmentTargetValue Value after nextSegmentDuration seconds. 
/// @param nextSegmentDuration    Duration in seconds.
- (void)addValue:(OCSConstantParam *)nextSegmentTargetValue 
   afterDuration:(OCSConstantParam *)nextSegmentDuration;


/// Adds a release segment.
/// @param finalValue      Last value to reach, typically zero.
/// @param releaseDuration Length of time in seconds to get to finalValue.
- (void)addReleaseToFinalValue:(OCSConstantParam *)finalValue 
                 afterDuration:(OCSConstantParam *)releaseDuration;

/// Switches to an exponential segment generating opcode.
- (void)useExponentialSegments;


@end
