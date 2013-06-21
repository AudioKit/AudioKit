//
//  OCSScaledControl.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSControl.h"
#import "OCSParameter+Operation.h"

/**
 Scales incoming value from 0 to 1 to user-definable range. 
 Similar to scale object found in popular dataflow languages.
 */

@interface OCSScaledControl : OCSControl

/// Create a control output based on control input scaled within an output range
/// @param inputControl  Input value in the range 0-1.
/// @param minimumOutput Minimum value of the resultant scale operation.
/// @param maximumOutput Maximum value of the resultant scale operation.
- (id)initWithControl:(OCSControl *)inputControl
        minimumOutput:(OCSControl *)minimumOutput
        maximumOutput:(OCSControl *)maximumOutput;

@end
