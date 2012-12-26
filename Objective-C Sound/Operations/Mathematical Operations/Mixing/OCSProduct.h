//
//  OCSProduct.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParameter+Operation.h"
#import "OCSAudio.h"

/** Multiplies any number of audio signals. 
 */

@interface OCSProduct : OCSAudio    

/// Initialization Statement
/// @param firstOperand At least one input is required
/// @param ...          End the list with a nil.
- (id)initWithOperands:(OCSAudio *)firstOperand,...;

@end
