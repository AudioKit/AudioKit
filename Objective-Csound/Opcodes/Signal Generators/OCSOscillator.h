//
//  OCSOscillator.h
//
//  Created by Aurelius Prochazka on 4/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/** A simple oscillator with linear interpolation.
 
 Reads from the function table sequentially and repeatedly at given frequency. 
 Linear interpolation is applied for table look up from internal phase values.
 */
@interface OCSOscillator : OCSOpcode 

/// The output as audio.
@property (nonatomic, strong) OCSParam *audio;
/// The output as a control.
@property (nonatomic, strong) OCSParamControl *control;
/// The output can either an audio signal or a control.
@property (nonatomic, strong) OCSParam *output;

/// Instantiates the oscillator with an initial phase of sampling.
/// @param functionTable Requires a wrap-around guard point.
/// @param initialPhase  Initial phase of sampling, expressed as a fraction of a cycle (0 to 1). A negative value will cause phase initialization to be skipped. 
/// @param amplitude     Amplitude of the output
/// @param frequency     Frequency in cycles per second.
- (id)initWithFunctionTable:(OCSFunctionTable *)functionTable
                  frequency:(OCSParam *)frequency
                  amplitude:(OCSParam *)amplitude 
                      phase:(OCSParamConstant *)initialPhase;

/// Instantiates the oscillator.
/// @param functionTable Requires a wrap-around guard point.
/// @param amplitude     Amplitude of the output
/// @param frequency     Frequency in cycles per second.
- (id)initWithFunctionTable:(OCSFunctionTable *)functionTable
                  frequency:(OCSParam *)frequency
                  amplitude:(OCSParam *)amplitude;




@end
