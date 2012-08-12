//
//  OCSProduct.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/** Multiplies any number of audio signals. 
 */

@interface OCSProduct : OCSOpcode 

/// @name Properties

/// The output is an audio signal.
@property (nonatomic, strong) OCSParameter *output;

/// @name Initialization

/// Initialization Statement
/// @param firstOperand At least one input is required
/// @param ...          End the list with a nil.
- (id)initWithOperands:(OCSParameter *)firstOperand,...;

@end
