//
//  OCSSum.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParameter+Operation.h"
#import "OCSAudio.h"

/// Sums any number of a-rate signals.
@interface OCSSum : OCSAudio

/// Create a new signal as a sum of given signals.
/// @param firstOperand At least one input is required
/// @param ...          End the list with a nil.
- (id)initWithOperands:(OCSParameter *)firstOperand,...;

@end
