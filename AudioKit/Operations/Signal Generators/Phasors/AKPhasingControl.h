//
//  AKPhasingControl.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** A normalized moving phase value.

 An internal phase is successively accumulated in accordance with the frequency to produce a moving phase value, normalized to lie in the range 0 <= phase < 1.
When used as the index to a table unit, this phase (multiplied by the desired function table length) will cause it to behave like an oscillator.
Note that phasor is a special kind of integrator, accumulating phase increments that represent frequency settings.
 */

@interface AKPhasingControl : AKControl
/// Instantiates the phasing control with all values
/// @param frequency Frequency in cycles per second. [Default Value: 1]
/// @param phase Initial phase, expressed as a fraction of a cycle (0 to 1). [Default Value: 0]
- (instancetype)initWithFrequency:(AKControl *)frequency
                            phase:(AKConstant *)phase;

/// Instantiates the phasing control with default values
- (instancetype)init;

/// Instantiates the phasing control with default values
+ (instancetype)control;


/// Frequency in cycles per second. [Default Value: 1]
@property AKControl *frequency;

/// Set an optional frequency
/// @param frequency Frequency in cycles per second. [Default Value: 1]
- (void)setOptionalFrequency:(AKControl *)frequency;

/// Initial phase, expressed as a fraction of a cycle (0 to 1). [Default Value: 0]
@property AKConstant *phase;

/// Set an optional phase
/// @param phase Initial phase, expressed as a fraction of a cycle (0 to 1). [Default Value: 0]
- (void)setOptionalPhase:(AKConstant *)phase;



@end
