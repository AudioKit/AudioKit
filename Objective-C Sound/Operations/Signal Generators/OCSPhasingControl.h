//
//  OCSPhasingControl.h
//  Sonification
//
//  Created by Adam Boulanger on 10/11/12.
//  Copyright (c) 2012 Adam Boulanger. All rights reserved.
//

#import "OCSParameter+Operation.h"

/** A normalized moving phase value.
 
 An internal phase is successively accumulated in accordance with the frequency to produce a moving phase value, normalized to lie in the range 0 <= phase < 1.
 
 When used as the index to a table unit, this phase (multiplied by the desired function table length) will cause it to behave like an oscillator.
 
 Note that phasor is a special kind of integrator, accumulating phase increments that represent frequency settings.
 */

@interface OCSPhasingControl : OCSParameter

//An internal phase is successively accumulated in accordance with the kcps or xcps frequency to produce a moving phase value, normalized to lie in the range 0 <= phs < 1.
//
//When used as the index to a table unit, this phase (multiplied by the desired function table length) will cause it to behave like an oscillator.
//
//Note that phasor is a special kind of integrator, accumulating phase increments that represent frequency settings.

/// Instantiates the phasor.
/// @param frequency Frequency in cycles per second.
- (id)initWithFrequency:(OCSControl *)frequency;

/// Set an optional phase of sampling
/// @param initialPhase  Initial phase, expressed as a fraction of a cycle (0 to 1).
- (void)setPhase:(OCSConstant *)phase;

@end
