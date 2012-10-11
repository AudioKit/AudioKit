//
//  OCSLinearControl.h
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 10/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSConstant.h"
#import "OCSParameter+Operation.h"

@interface OCSLinearControl : OCSControl

/// Initialize a linear transition from one value to another over specified time.
/// @param startingValue Value to start the line from.
/// @param endingValue   Value to end the line at.
/// @param duration      Duration of linear transition in seconds.
/// @return An opcode to perform a linear transition over a given duration.
- (id)initFromValue:(OCSConstant *)startingValue
            toValue:(OCSConstant *)endingValue
           duration:(OCSConstant *)duration;


@end
