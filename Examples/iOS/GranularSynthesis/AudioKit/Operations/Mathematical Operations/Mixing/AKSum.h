//
//  AKSum.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKParameter+Operation.h"
#import "AKAudio.h"

/// Sums any number of a-rate signals.
@interface AKSum : AKAudio

/// Create a new signal as a sum of given signals.
/// @param firstOperand At least one input is required
/// @param ...          End the list with a nil.
- (instancetype)initWithOperands:(AKParameter *)firstOperand,...;

@end
