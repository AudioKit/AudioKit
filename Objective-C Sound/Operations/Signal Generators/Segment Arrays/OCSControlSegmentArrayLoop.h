//
//  OCSControlSegmentArrayLoop.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 11/6/12
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSControl.h"
#import "OCSParameter+Operation.h"

/** Generate control signal consisting of linear segments delimited by two or more specified points.
 
 Generate control signal consisting of linear segments delimited by two or more specified points. The entire envelope is looped at a rate defined byt frequency. Each parameter can be varied as controls.
 */

@interface OCSControlSegmentArrayLoop : OCSControl

/// Instantiates the control segment array loop
/// @param frequency Repeat rate in Hz or fraction of Hz.
/// @param startValue Initial value at time zero.
- (instancetype)initWithFrequency:(OCSControl *)frequency
             startValue:(OCSControl *)startValue;

/// Adds another segment.
/// @param nextSegmentTargetValue Value after nextSegmentDuration seconds.
/// @param durationFraction Duration of points; expressed in fraction of a cycle.
- (void)addValue:(OCSControl *)nextSegmentTargetValue
   afterDuration:(OCSControl *)durationFraction;

/// Switches to an exponential segment generating opcode.
- (void)useExponentialSegments;

@end