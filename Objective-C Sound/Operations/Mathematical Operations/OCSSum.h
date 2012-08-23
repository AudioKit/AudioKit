//
//  OCSSum.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOperation.h"

/// Sums any number of a-rate signals.
@interface OCSSum : OCSOperation 

/// @name Properties

/// The output is an audio signal.
@property (nonatomic, strong) OCSParameter *output;

/// @name Initialization

/// Create a new signal as a sum of given signals.
/// @param firstOperand At least one input is required
/// @param ...          End the list with a nil.
- (id)initWithOperands:(OCSParameter *)firstOperand,...;

@end
