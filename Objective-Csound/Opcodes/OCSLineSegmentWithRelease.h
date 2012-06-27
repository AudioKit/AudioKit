//
//  LineSegmentWithRelease.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/** Trace a series of line segments between specified points including a release segment.
 
 These units generate control or audio signals whose values can pass through 2 or more specified points. The sum of dur values may or may not equal the instrument's performance time: a shorter performance will truncate the specified pattern, while a longer one will cause the last-defined segment to continue on in the same direction.
 
 linsegr is amongst the Csound “r” units that contain a note-off sensor and release time extender. When each senses an event termination or MIDI noteoff, it immediately extends the performance time of the current instrument by irel seconds, and sets out to reach the value iz by the end of that period (no matter which segment the unit is in). “r” units can also be modified by MIDI noteoff velocities. For two or more extenders in an instrument, extension is by the greatest period.
 
 You can use other pre-made envelopes which start a release segment upon recieving a note off message, like linenr and expsegr, or you can construct more complex envelopes using xtratim and release. Note that you don't need to use xtratim if you are using linsegr, since the time is extended automatically.
 
 http://www.csounds.com/manual/html/linsegr.html
 */

@interface OCSLineSegmentWithRelease : OCSOpcode

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
                  DurationValuePairs:(OCSParamArray *)durationValuePairs              
                     ReleaseDuration:(OCSParamConstant *)releaseDuration
                          FinalValue:(OCSParamConstant *)finalValue;

/// Creates a single exponential segment.
/// @param firstSegmentStartValue  Starting value. Zero is illegal for exponentials.
/// @param firstSegmentTargetValue Value after duration seconds.  For exponentials, must be non-zero and must agree in sign with starting value.
/// @param firstSegmentDuration    Duration in seconds of first segment. A zero or negative value will cause all initialization to be skipped.
- (id)initWithFirstSegmentStartValue:(OCSParamConstant *)firstSegmentStartValue
             FirstSegmentTargetValue:(OCSParamConstant *)firstSegmentTargetValue
                FirstSegmentDuration:(OCSParamConstant *)firstSegmentDuration               
                     ReleaseDuration:(OCSParamConstant *)releaseDuration
                          FinalValue:(OCSParamConstant *)finalValue;


@end
