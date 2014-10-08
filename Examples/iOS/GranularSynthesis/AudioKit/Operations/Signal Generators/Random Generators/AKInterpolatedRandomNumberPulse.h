//
//  AKInterpolatedRandomNumberPulse.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 8/3/14.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** Generates a controlled random number series with interpolation between each new number.
 
 New random numbers are generated at a given frequency between zero and a maximum upper bound.  In between random numbers, the value of this operation is linearly interpolated between the two numbers in time.
 */

@interface AKInterpolatedRandomNumberPulse : AKControl

/// Instantiates the nterpolated random number pulse
/// @param maximum Maximum maximum range limit.  Sampled values will be between 0 and this maximum
/// @param frequency Frequency at which the new numbers are generated.
- (instancetype)initWithMaximum:(AKControl *)maximum
                      frequency:(AKControl *)frequency;

@end