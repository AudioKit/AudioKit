//
//  OCSOscillator.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** A simple oscillator with linear interpolation.
 
 Reads from the function table sequentially and repeatedly at given frequency. 
 Linear interpolation is applied for table look up from internal phase values.
 */

@interface OCSOscillator : OCSAudio

/// Instantiates the oscillator
/// @param fTable    Requires a wrap-around guard point
/// @param frequency Frequency in cycles per second
/// @param amplitude Amplitude of the output
- (id)initWithFTable:(OCSFTable *)fTable
           frequency:(OCSParameter *)frequency
           amplitude:(OCSParameter *)amplitude;

/// Set an optional phase
/// @param phase Comment
- (void)setPhase:(OCSConstant *)phase;

@end