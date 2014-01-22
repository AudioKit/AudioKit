//
//  AKOscillator.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A simple oscillator with linear interpolation.
 
 Reads from the function table sequentially and repeatedly at given frequency. Linear interpolation is applied for table look up from internal phase values.
 */

@interface AKOscillator : AKAudio

/// Instantiates the oscillator
/// @param fTable Requires a wrap-around guard point
/// @param frequency Frequency in cycles per second
/// @param amplitude Amplitude of the output
- (instancetype)initWithFTable:(AKFTable *)fTable
                     frequency:(AKParameter *)frequency
                     amplitude:(AKParameter *)amplitude;


/// Set an optional phase
/// @param phase Initial phase of sampling, expressed as a fraction of a cycle (0 to 1). A negative value will cause phase initialization to be skipped. The default value is 0.
- (void)setOptionalPhase:(AKConstant *)phase;


@end