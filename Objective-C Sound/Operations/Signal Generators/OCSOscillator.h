//
//  OCSOscillator.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 4/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOperation.h"

/** A simple oscillator with linear interpolation.
 
 Reads from the function table sequentially and repeatedly at given frequency. 
 Linear interpolation is applied for table look up from internal phase values.
 */
@interface OCSOscillator : OCSOperation 

/// @name Properties

/// The output as audio.
@property (nonatomic, strong) OCSParameter *audio;
/// The output as a control.
@property (nonatomic, strong) OCSControl *control;
/// The output can either an audio signal or a control.
@property (nonatomic, strong) OCSParameter *output;

/// @name Initialization

/// Instantiates the oscillator with an initial phase of sampling.
/// @param fTable Requires a wrap-around guard point.
/// @param initialPhase  Initial phase of sampling, expressed as a fraction of a cycle (0 to 1). A negative value will cause phase initialization to be skipped. 
/// @param amplitude     Amplitude of the output
/// @param frequency     Frequency in cycles per second.
- (id)initWithFTable:(OCSFTable *)fTable
               phase:(OCSConstant *)initialPhase
           frequency:(OCSParameter *)frequency
           amplitude:(OCSParameter *)amplitude;

/// Instantiates the oscillator.
/// @param fTable Requires a wrap-around guard point.
/// @param amplitude     Amplitude of the output
/// @param frequency     Frequency in cycles per second.
- (id)initWithFTable:(OCSFTable *)fTable
           frequency:(OCSParameter *)frequency
           amplitude:(OCSParameter *)amplitude;




@end
