//
//  OCSRandomControl.h
//  Objective-C Sound
//
//  Created by Adam Boulanger on 9/29/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParameter+Operation.h"

/**
 Generates random control values based on a controlled pseudo-random number series between minimum and maximum values.
 */

@interface OCSRandomControl : OCSControl

/// Instantiates the oscillator with an initial phase of sampling.
/// @param minimum minimum range limit
/// @param maximum maximum range limit
- (instancetype)initWithMinimum:(OCSControl *)minimum
              maximum:(OCSControl *)maximum;

@end
