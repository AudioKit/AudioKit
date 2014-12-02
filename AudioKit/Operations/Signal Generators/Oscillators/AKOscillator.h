//
//  AKOscillator.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/1/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A simple oscillator with linear interpolation.

 Reads from the function table sequentially and repeatedly at given frequency. Linear interpolation is applied for table look up from internal phase values.
 */

@interface AKOscillator : AKAudio

/// Instantiates the oscillator with all values
/// @param frequency Frequency in cycles per second
/// @param fTable Requires a wrap-around guard point
/// @param phase Initial phase of sampling, expressed as a fraction of a cycle (0 to 1). A negative value will cause phase initialization to be skipped. The default value is 0.
- (instancetype)initWithFrequency:(AKParameter *)frequency
                           fTable:(AKFTable *)fTable
                            phase:(AKConstant *)phase;

/// Instantiates the oscillator with default values
- (instancetype)init;


/// Instantiates the oscillator with default values
+ (instancetype)audio;




/// Frequency in cycles per second [Default Value: 440]
@property AKParameter *frequency;

/// Set an optional frequency
/// @param frequency Frequency in cycles per second [Default Value: 440]
- (void)setOptionalFrequency:(AKParameter *)frequency;


/// Requires a wrap-around guard point [Default Value: sine]
@property AKFTable *fTable;

/// Set an optional f table
/// @param fTable Requires a wrap-around guard point [Default Value: sine]
- (void)setOptionalFTable:(AKFTable *)fTable;


/// Initial phase of sampling, expressed as a fraction of a cycle (0 to 1). A negative value will cause phase initialization to be skipped. The default value is 0. [Default Value: 0]
@property AKConstant *phase;

/// Set an optional phase
/// @param phase Initial phase of sampling, expressed as a fraction of a cycle (0 to 1). A negative value will cause phase initialization to be skipped. The default value is 0. [Default Value: 0]
- (void)setOptionalPhase:(AKConstant *)phase;


@end
