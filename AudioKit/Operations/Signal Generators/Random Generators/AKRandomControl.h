//
//  AKRandomControl.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** Generates a controlled pseudo-random number series between min and max values.
 */

@interface AKRandomControl : AKControl

/// Instantiates the random control
/// @param minimum Minimum range limit.
/// @param maximum Maximum range limit
- (instancetype)initWithMinimum:(AKControl *)minimum
                        maximum:(AKControl *)maximum;

@end