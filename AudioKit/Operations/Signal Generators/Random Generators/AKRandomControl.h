//
//  AKRandomControl.h
//  AudioKit
//
//  Auto-generated on 12/25/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** Generates a controlled pseudo-random number series between min and max values.

 More detailed description from http://www.csounds.com/manual/html/random.html
 */

@interface AKRandomControl : AKControl
/// Instantiates the random control with all values
/// @param lowerBound Minimum range limit. Updated at Control-rate. [Default Value: 0]
/// @param upperBound Maximum range limit. Updated at Control-rate. [Default Value: 1]
- (instancetype)initWithLowerBound:(AKParameter *)lowerBound
                        upperBound:(AKParameter *)upperBound;

/// Instantiates the random control with default values
- (instancetype)init;

/// Instantiates the random control with default values
+ (instancetype)control;


/// Minimum range limit. [Default Value: 0]
@property AKParameter *lowerBound;

/// Set an optional lower bound
/// @param lowerBound Minimum range limit. Updated at Control-rate. [Default Value: 0]
- (void)setOptionalLowerBound:(AKParameter *)lowerBound;

/// Maximum range limit. [Default Value: 1]
@property AKParameter *upperBound;

/// Set an optional upper bound
/// @param upperBound Maximum range limit. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalUpperBound:(AKParameter *)upperBound;



@end
