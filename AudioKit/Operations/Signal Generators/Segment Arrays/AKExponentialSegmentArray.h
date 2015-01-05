//
//  AKExponentialSegmentArray.h
//  AKLinearSegmentArray
//
//  Created by Aurelius Prochazka on 1/4/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKParameter+Operation.h"

/** Trace a series of exponential segments between specified points.
 */
@interface AKExponentialSegmentArray : AKParameter

/// Creates the exponential segment array and populates it with the minimum information.
/// Use addValue:afterDuration to add more segments to the array.
/// An optional release segment can be added with addReleaseToFinalValue:afterDuration.
/// @param initialValue Starting value.
/// @param targetValue Value after time given by duration.
/// @param duration Duration in seconds of first segment.
- (instancetype)initWithInitialValue:(AKConstant *)initialValue
                         targetValue:(AKConstant *)targetValue
                       afterDuration:(AKConstant *)duration;

/// Adds another segment.
/// @param value Value after time given by duration.
/// @param duration Duration in seconds.
- (void)addValue:(AKConstant *)value
   afterDuration:(AKConstant *)duration;

@end

