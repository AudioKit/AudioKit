//
//  OCSRandom.h
//  OCS iPad Examples
//
//  Created by Adam Boulanger on 9/29/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParameter+Operation.h"

/**
 Generates is a controlled pseudo-random number series between min and max values.
 */

@interface OCSRandom : OCSParameter

/// @name Properties

/// The output as a control.
@property (nonatomic, strong) OCSControl *control;

/// The output as a constant.
@property (nonatomic, strong) OCSConstant *constant;

/// The output can either be an audio signal, a control, or a constant.
@property (nonatomic, strong) OCSParameter *output;

/// @name Initialization

/// Instantiates the oscillator with an initial phase of sampling.
/// @param minimum minimum range limit
/// @param maximum maximum range limit
- (id)initWithMinimum:(OCSControl *)minimum
              maximum:(OCSControl *)maximum;

@end
