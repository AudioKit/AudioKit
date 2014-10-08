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

/// Initialization Statement
/// @param firstOperand At least one input is required
/// @param ...          End the list with a nil.
- (instancetype)initWithOperands:(AKAudio *)firstOperand,...;

@end
