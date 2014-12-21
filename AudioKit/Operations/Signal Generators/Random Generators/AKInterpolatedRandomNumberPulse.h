//
//  AKInterpolatedRandomNumberPulse.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** Generates a controlled random number series with interpolation between each new number.

 New random numbers are generated at a given frequency between zero and a maximum upper bound.  In between random numbers, the value of this operation is linearly interpolated between the two numbers in time.
 */

@interface AKInterpolatedRandomNumberPulse : AKControl
/// Instantiates the interpolated random number pulse with all values
/// @param upperBound Maximum maximum range limit.  Sampled values will be between 0 and this maximum [Default Value: 1]
/// @param frequency Frequency at which the new numbers are generated in Hz. [Default Value: 1]
- (instancetype)initWithUpperBound:(AKControl *)upperBound
                         frequency:(AKControl *)frequency;

/// Instantiates the interpolated random number pulse with default values
- (instancetype)init;

/// Instantiates the interpolated random number pulse with default values
+ (instancetype)control;


/// Maximum maximum range limit.  Sampled values will be between 0 and this maximum [Default Value: 1]
@property AKControl *upperBound;

/// Set an optional upper bound
/// @param upperBound Maximum maximum range limit.  Sampled values will be between 0 and this maximum [Default Value: 1]
- (void)setOptionalUpperBound:(AKControl *)upperBound;

/// Frequency at which the new numbers are generated in Hz. [Default Value: 1]
@property AKControl *frequency;

/// Set an optional frequency
/// @param frequency Frequency at which the new numbers are generated in Hz. [Default Value: 1]
- (void)setOptionalFrequency:(AKControl *)frequency;



@end
