//
//  AKPhasorControl.h
//  EasyExponentialCurves
//
//  Created by Adam Boulanger on 1/21/15.
//  Copyright (c) 2015 Adam Boulanger. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** A normalized moving phase value.
 
 An internal phase is successively accumulated in accordance with the frequency to produce a moving phase value, normalized to lie in the range 0 <= phase < 1.
 When used as the index to a table unit, this phase (multiplied by the desired function table length) will cause it to behave like an oscillator.
 Note that phasor is a special kind of integrator, accumulating phase increments that represent frequency settings.
 */

@interface AKPhasorControl : AKControl
/// Instantiates the phasor with all values
/// @param frequency Frequency in cycles per second. [Default Value: 440]
/// @param phase Initial phase, expressed as a fraction of a cycle (0 to 1). [Default Value: 0]
- (instancetype)initWithFrequency:(AKParameter *)frequency
                            phase:(AKConstant *)phase;

/// Instantiates the phasor with default values
- (instancetype)init;

/// Instantiates the phasor with default values
+ (instancetype)phasor;


/// Frequency in cycles per second. [Default Value: 440]
@property AKParameter *frequency;

/// Set an optional frequency
/// @param frequency Frequency in cycles per second. [Default Value: 440]
- (void)setOptionalFrequency:(AKParameter *)frequency;

/// Initial phase, expressed as a fraction of a cycle (0 to 1). [Default Value: 0]
@property AKConstant *phase;

/// Set an optional phase
/// @param phase Initial phase, expressed as a fraction of a cycle (0 to 1). [Default Value: 0]
- (void)setOptionalPhase:(AKConstant *)phase;

@end