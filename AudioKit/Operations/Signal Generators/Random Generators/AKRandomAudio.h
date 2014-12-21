//
//  AKRandomAudio.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Generates a controlled pseudo-random number series between min and max values.

 More detailed description from http://www.csounds.com/manual/html/random.html
 */

@interface AKRandomAudio : AKAudio
/// Instantiates the random audio with all values
/// @param lowerBound Minimum range limit. [Default Value: 0]
/// @param upperBound Maximum range limit. [Default Value: 1]
- (instancetype)initWithLowerBound:(AKControl *)lowerBound
                        upperBound:(AKControl *)upperBound;

/// Instantiates the random audio with default values
- (instancetype)init;

/// Instantiates the random audio with default values
+ (instancetype)audio;


/// Minimum range limit. [Default Value: 0]
@property AKControl *lowerBound;

/// Set an optional lower bound
/// @param lowerBound Minimum range limit. [Default Value: 0]
- (void)setOptionalLowerBound:(AKControl *)lowerBound;

/// Maximum range limit. [Default Value: 1]
@property AKControl *upperBound;

/// Set an optional upper bound
/// @param upperBound Maximum range limit. [Default Value: 1]
- (void)setOptionalUpperBound:(AKControl *)upperBound;



@end
