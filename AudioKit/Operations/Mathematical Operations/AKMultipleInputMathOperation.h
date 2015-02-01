//
//  AKMultipleInputMathOperation.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/1/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKParameter+Operation.h"

@interface AKMultipleInputMathOperation : AKParameter

/// Create a new signal as a sum of given signals.
/// @param firstOperand At least one input is required
/// @param ...          End the list with a nil.
- (instancetype)initWithOperands:(AKParameter *)firstOperand,...;


/// Create a new signal as a sum of exactly two given signals.
/// @param firstOperand First signal to be summed.
/// @param secondOperand Second Signal to be summed.
- (instancetype)initWithFirstOperand:(AKParameter *)firstOperand
                       secondOperand:(AKParameter *)secondOperand;

@end
