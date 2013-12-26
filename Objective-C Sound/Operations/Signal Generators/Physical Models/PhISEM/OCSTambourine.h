//
//  OCSTambourine.h
//  Objective-C Sound
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** Semi-physical model of a tambourine sound.
 
 This is one of the PhISEM percussion opcodes. PhISEM (Physically Informed Stochastic Event Modeling) is an algorithmic approach for simulating collisions of multiple independent sound producing objects.
 */

@interface OCSTambourine : OCSAudio

/// Instantiates the tambourine
/// @param maximumDuration Period of time over which all sound is stopped
/// @param amplitude Amplitude of output. Since these instruments are stochastic this is only an approximation.
- (instancetype)initWithMaximumDuration:(OCSConstant *)maximumDuration
                              amplitude:(OCSControl *)amplitude;


/// Set an optional count
/// @param count The number of beads/teeth/bells/timbrels/etc. The default value is 32.
- (void)setOptionalCount:(OCSConstant *)count;

/// Set an optional damping factor
/// @param dampingFactor The damping factor, as part of this equation damping = 0.9985 + (dampingFactor * 0.002) The default damping is 0.9985 which means that the default value is 0. The maximum damping is 1.0 (no damping). This means the maximum value for the dampingFactor is 0.05.  The recommended range for dampingFactor is usually below 75% of the maximum value.
- (void)setOptionalDampingFactor:(OCSConstant *)dampingFactor;

/// Set an optional energy return
/// @param energyReturn Amount of energy to add back into the system. The value should be in range 0 to 1.
- (void)setOptionalEnergyReturn:(OCSConstant *)energyReturn;

/// Set an optional main resonant frequency
/// @param mainResonantFrequency The main resonant frequency. The default value is 2300.
- (void)setOptionalMainResonantFrequency:(OCSConstant *)mainResonantFrequency;

/// Set an optional first resonant frequency
/// @param firstResonantFrequency The first resonant frequency. The default value is 5600.
- (void)setOptionalFirstResonantFrequency:(OCSConstant *)firstResonantFrequency;

/// Set an optional second resonant frequency
/// @param secondResonantFrequency The second resonant frequency. The default value is 8100.
- (void)setOptionalSecondResonantFrequency:(OCSConstant *)secondResonantFrequency;


@end