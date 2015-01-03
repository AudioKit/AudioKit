//
//  AKOscillator.h
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A simple oscillator with linear interpolation.

 Reads from the function table sequentially and repeatedly at given frequency. Linear interpolation is applied for table look up from internal phase values.
 */

@interface AKOscillator : AKAudio
/// Instantiates the oscillator with all values
/// @param functionTable Requires a wrap-around guard point [Default Value: sine]
/// @param frequency Frequency in cycles per second [Default Value: 440]
/// @param amplitude Amplitude of the output [Default Value: 1]
- (instancetype)initWithFunctionTable:(AKFunctionTable *)functionTable
                            frequency:(AKParameter *)frequency
                            amplitude:(AKParameter *)amplitude;

/// Instantiates the oscillator with default values
- (instancetype)init;

/// Instantiates the oscillator with default values
+ (instancetype)oscillator;


/// Requires a wrap-around guard point [Default Value: sine]
@property AKFunctionTable *functionTable;

/// Set an optional function table
/// @param functionTable Requires a wrap-around guard point [Default Value: sine]
- (void)setOptionalFunctionTable:(AKFunctionTable *)functionTable;

/// Frequency in cycles per second [Default Value: 440]
@property AKParameter *frequency;

/// Set an optional frequency
/// @param frequency Frequency in cycles per second [Default Value: 440]
- (void)setOptionalFrequency:(AKParameter *)frequency;

/// Amplitude of the output [Default Value: 1]
@property AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude of the output [Default Value: 1]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;



@end
