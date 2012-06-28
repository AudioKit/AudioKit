//
//  OCSSum.h
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/// Sums any number of a-rate signals.
@interface OCSSum : OCSOpcode 

/// The output is an audio signal.
@property (nonatomic, strong) OCSParam *output;

/// Create a new signal as a sum of given signals.
/// @param firstOperand At least one input is required
/// @param ...          End the list with a nil.
- (id)initWithOperands:(OCSParam *)firstOperand,...;

@end
