//
//  AKProduct.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKParameter+Operation.h"
#import "AKAudio.h"

/** Multiplies any number of audio signals. 
 */

@interface AKProduct : AKAudio    

@property NSArray *inputs;

/// Initialization Statement
/// @param firstOperand At least one input is required
/// @param ...          End the list with a nil.
- (instancetype)initWithOperands:(AKAudio *)firstOperand,...;

/// Create a new signal as a product of exactly two given signals.
/// @param firstOperand First signal to be summed.
/// @param secondOperand Second Signal to be summed.
- (instancetype)initWithFirstOperand:(AKParameter *)firstOperand
                    secondOperand:(AKParameter *)secondOperand;

@end
