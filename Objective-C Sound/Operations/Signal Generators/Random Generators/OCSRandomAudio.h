//
//  OCSRandomAudio.h
//  Objective-C Sound
//
//  Created by Adam Boulanger on 9/29/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/**
 Generates noise based on a controlled pseudo-random number series between minimum and maximum values.
 */

@interface OCSRandomAudio : OCSAudio

/// Instantiates the oscillator with an initial phase of sampling.
/// @param minimum minimum range limit
/// @param maximum maximum range limit
- (id)initWithMinimum:(OCSControl *)minimum
              maximum:(OCSControl *)maximum;

@end
