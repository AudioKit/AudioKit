//
//  AKOscillator.h
//  AudioKit
//
//  Auto-generated on 12/25/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A simple oscillator with linear interpolation.

 Reads from the function table sequentially and repeatedly at given frequency. Linear interpolation is applied for table look up from internal phase values.
 */

@interface AKOscillator : AKAudio
/// Instantiates the oscillator with all values
/// @param fTable Requires a wrap-around guard point [Default Value: sine]
/// @param frequency Frequency in cycles per second [Default Value: 440]
/// @param amplitude Amplitude of the output [Default Value: 1]
/// @param phase Initial phase of sampling, expressed as a fraction of a cycle (0 to 1). A negative value will cause phase initialization to be skipped. The default value is 0. [Default Value: 0]
- (instancetype)initWithFTable:(AKFTable *)fTable
                     frequency:(AKParameter *)frequency
                     amplitude:(AKParameter *)amplitude
                         phase:(AKConstant *)phase;

/// Instantiates the oscillator with default values
- (instancetype)init;

/// Instantiates the oscillator with default values
+ (instancetype)audio;


/// Requires a wrap-around guard point [Default Value: sine]
@property AKFTable *fTable;

/// Set an optional f table
/// @param fTable Requires a wrap-around guard point [Default Value: sine]
- (void)setOptionalFTable:(AKFTable *)fTable;

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

/// Initial phase of sampling, expressed as a fraction of a cycle (0 to 1). A negative value will cause phase initialization to be skipped. The default value is 0. [Default Value: 0]
@property AKConstant *phase;

/// Set an optional phase
/// @param phase Initial phase of sampling, expressed as a fraction of a cycle (0 to 1). A negative value will cause phase initialization to be skipped. The default value is 0. [Default Value: 0]
- (void)setOptionalPhase:(AKConstant *)phase;



@end
