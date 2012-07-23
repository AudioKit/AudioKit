//
//  OCSScaledControl.h
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/**
 Scales incoming value from 0 to 1 to user-definable range. 
 Similar to scale object found in popular dataflow languages.
 */

@interface OCSScaledControl : OCSOpcode

/// Output is the scaled control-rate value.
@property (nonatomic, strong) OCSControl *output;
/// Input value in the range 0-1.
@property (nonatomic, strong) OCSControl *input;
/// Minimum value of the resultant scale operation.
@property (nonatomic, strong) OCSControl *minimumOutput;
/// Maximum value of the resultant scale operation.
@property (nonatomic, strong) OCSControl *maximumOutput;

/// Create a control output based on control input scaled within an output range
/// @param input         Input value in the range 0-1.
/// @param minimumOutput Minimum value of the resultant scale operation.
/// @param maximumOutput Maximum value of the resultant scale operation.
- (id)initWithInput:(OCSControl *)input
      minimumOutput:(OCSControl *)minimumOutput
      maximumOutput:(OCSControl *)maximumOutput;

@end
