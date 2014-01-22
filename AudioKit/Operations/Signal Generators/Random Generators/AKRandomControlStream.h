//
//  AKRandomControlStream.h
//  WindSounds
//
//  Created by Adam Boulanger on 9/30/13.
//  Copyright (c) 2013 Hear For Yourself. All rights reserved.
//

#import "AKParameter+Operation.h"

/**
 Generates a controlled random number series with interpolation between each new number.
 */
@interface AKRandomControlStream : AKControl

/// Instantiates the oscillator with an initial frequency of sampling.
/// @param maximum maximum range limit.  Sampled values will be between 0 .. maximum
/// @param frequency frequency with which new samples are generated
- (instancetype)initWithMaximum:(AKControl *)maximum
                      frequency:(AKControl *)frequency;

/// Sets optional seed value for the pseudo-random number generator.
/// @param seed seed value for the recursive pseudo-random formula. A value between 0 and +1 will produce an initial output of kamp * iseed. A negative value will cause seed re-initialization to be skipped. A value greater than 1 will seed from system time, this is the best option to generate a different random sequence for each run.
- (void)setOptionalSeed:(AKConstant *)seed;

/// Sets an optional offset
///  @param offset Base Value added to the random result
- (void)setOptionalOffset:(AKConstant *)offset;

/// Initial seed value of pseudo-random number generator will be derived from system clock.
- (void)useSystemSeed;

/// Generated output will be a 31-bit value rather than the default 16-bit value.
- (void)useThirtyOneBitOutput;

@end
