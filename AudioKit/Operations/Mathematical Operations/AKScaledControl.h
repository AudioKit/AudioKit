//
//  AKScaledControl.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** Scales incoming value from 0 to 1 to user-definable range.

 Similar to scale object found in popular dataflow languages.
 */

@interface AKScaledControl : AKControl

/// Create a control output based on control input scaled within an output range
/// @param inputControl  Input value in the range 0-1.
/// @param minimumOutput Minimum value of the resultant scale operation.
/// @param maximumOutput Maximum value of the resultant scale operation.
- (instancetype)initWithControl:(AKControl *)inputControl
                  minimumOutput:(AKControl *)minimumOutput
                  maximumOutput:(AKControl *)maximumOutput;

@end
