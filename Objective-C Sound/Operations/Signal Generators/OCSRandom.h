//
//  OCSRandom.h
//  OCS iPad Examples
//
//  Created by Adam Boulanger on 9/29/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOperation.h"

/**
 Generates is a controlled pseudo-random number series between min and max values.
 */

@interface OCSRandom : OCSOperation

/// @name Properties

/// The output as audio.
@property (nonatomic, strong) OCSParameter *audio;

/// The output as a control.
@property (nonatomic, strong) OCSControl *control;

/// The output as a constant.
@property (nonatomic, strong) OCSConstant *constant;

/// The output can either be an audio signal, a control, or a constant.
@property (nonatomic, strong) OCSParameter *output;

/// @name Initialization

/// Instantiates the oscillator with an initial phase of sampling.
/// @param minimumValue minimum range limit
/// @param maximumValue maximum range limit
- (id)initWithMinimumValue:(OCSParameter *)minimumRange
              maximumValue:(OCSParameter *)maximumRange;

@end
