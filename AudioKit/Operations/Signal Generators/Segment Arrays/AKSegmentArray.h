//
//  AKSegmentArray.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/4/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKParameter+Operation.h"

/** Trace a series of linear or exponential segments between specified points.
 */
NS_ASSUME_NONNULL_BEGIN
@interface AKSegmentArray : AKParameter

/// Creates the exponential segment array and populates it with the minimum information.
/// Use addValue:afterDuration to add more segments to the array.
/// An optional release segment can be added with addReleaseToFinalValue:afterDuration.
/// @param initialValue Starting value.
/// @param targetValue Value after time given by duration.
/// @param duration Duration in seconds of first segment.
/// @param concavity A value greater than zero is an initially slower change and less than zero is a quicker intial change.  Use zero for a linear change.
- (instancetype)initWithInitialValue:(AKConstant *)initialValue
                         targetValue:(AKConstant *)targetValue
                       afterDuration:(AKConstant *)duration
                           concavity:(AKConstant *)concavity;


/// Adds another segment.
/// @param value Value after time given by duration.
/// @param duration Duration in seconds.
/// @param concavity A value greater than zero is an initially slower change and less than zero is a quicker intial change.  Use zero for a linear change.
- (void)addValue:(AKConstant *)value
   afterDuration:(AKConstant *)duration
       concavity:(AKConstant *)concavity;

/// Creates the exponential segment array and populates it with the minimum information.
/// Use addValue:afterDuration to add more segments to the array.
/// An optional release segment can be added with addReleaseToFinalValue:afterDuration.
/// @param initialValue Starting value.
/// @param targetValue Value after time given by duration.
/// @param duration Duration in seconds of first segment.
- (instancetype)initWithInitialValue:(AKConstant *)initialValue
                         targetValue:(AKConstant *)targetValue
                       afterDuration:(AKConstant *)duration;

/// Adds a linear segment
/// @param value Value after time given by duration.
/// @param duration Duration in seconds.
- (void)addValue:(AKConstant *)value
   afterDuration:(AKConstant *)duration;

/// Creates a release segment.
/// @param value Value after time given by duration.
/// @param duration Duration in seconds.
/// @param concavity A value greater than zero is an initially slower change and less than zero is a quicker intial change.  Use zero for a linear change.
- (void)releaseToValue:(AKConstant *)value
         afterDuration:(AKConstant *)duration
             concavity:(AKConstant *)concavity;


@end
NS_ASSUME_NONNULL_END

