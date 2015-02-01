//
//  AKMultipleInputMathOperation.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/1/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKParameter+Operation.h"

@interface AKMultipleInputMathOperation : AKParameter

@property NSArray *inputs;

/// Create a new signal as a sum of given signals.
/// @param firstInput At least one input is required
/// @param ...          End the list with a nil.
- (instancetype)initWithInputs:(AKParameter *)firstInput,...;


/// Create a new signal as a sum of exactly two given signals.
/// @param firstInput First signal to be summed.
/// @param secondInput Second Signal to be summed.
- (instancetype)initWithFirstInput:(AKParameter *)firstInput
                       secondInput:(AKParameter *)secondInput;

@end
