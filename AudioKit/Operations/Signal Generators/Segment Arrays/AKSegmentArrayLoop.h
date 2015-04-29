//
//  AKSegmentArrayLoop.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/14/15
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** Generate control signal consisting of linear or exponential segments.

 Generate control signal consisting of linear segments delimited by two or more specified points. The entire envelope is looped at a rate defined by frequency. Each parameter can be varied as controls.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKSegmentArrayLoop : AKControl

/// Instantiates the control segment array loop
/// @param frequency Repeat rate in Hz or fraction of Hz.
/// @param initialValue Initial value at time zero.
- (instancetype)initWithFrequency:(AKParameter *)frequency
                     initialValue:(AKParameter *)initialValue;

/// Adds another segment.
/// @param value Value after nextSegmentDuration seconds.
/// @param duration Dimensionless duration - sum all durations will be rescaled to the period given by the inverse of the frequency of the loop
/// @param concavity A value greater than zero is an initially slower change and less than zero is a quicker intial change.  Use zero for a linear change.
- (void)addValue:(AKParameter *)value
   afterDuration:(AKParameter *)duration
       concavity:(AKParameter *)concavity;

@end
NS_ASSUME_NONNULL_END
