//
//  OCSOscillator.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 4/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParameter+Operation.h"


/** A simple oscillator with linear interpolation.
 
 Reads from the function table sequentially and repeatedly at given frequency. 
 Linear interpolation is applied for table look up from internal phase values.
 */

@interface OCSOscillator : OCSParameter

/// Instantiates the oscillator.
/// @param fTable Requires a wrap-around guard point.
/// @param amplitude Amplitude of the output
/// @param frequency Frequency in cycles per second.
- (id)initWithFTable:(OCSFTable *)fTable
           frequency:(OCSParameter *)frequency
           amplitude:(OCSParameter *)amplitude;

/// Set an optional phase of sampling
/// @param initialPhase  Initial phase of sampling, expressed as a fraction of a cycle (0 to 1).
- (void)setPhase:(OCSConstant *)initialPhase;



@end
