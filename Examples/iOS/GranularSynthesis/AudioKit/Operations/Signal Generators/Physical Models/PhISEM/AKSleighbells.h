//
//  AKSleighbells.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Semi-physical model of a sleighbell sound.
 
 This is one of the PhISEM percussion opcodes. PhISEM (Physically Informed Stochastic Event Modeling) is an algorithmic approach for simulating collisions of multiple independent sound producing objects.
 */

@interface AKSleighbells : AKAudio

/// Instantiates the sleighbells
/// @param duration Period of time over which all sound is stopped
/// @param amplitude Amplitude of output. Since these instruments are stochastic this is only an approximation.
- (instancetype)initWithDuration:(AKConstant *)duration
                       amplitude:(AKControl *)amplitude;


/// Set an optional count
/// @param count The number of beads/teeth/bells/timbrels/etc. The default value is 1.25.
- (void)setOptionalCount:(AKConstant *)count;

/// Set an optional damping factor
/// @param dampingFactor The damping factor, as part of this equation damping = 0.9994 + (dampingFactor * 0.002). The default damping is 0.9994 which means that the default value is 0. The maximum damping is 1.0 (no damping). This means the maximum value for the dampingFactor is 0.03.  The recommended range for dampingFactor is usually below 75% of the maximum value.
- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor;

/// Set an optional energy return
/// @param energyReturn Amount of energy to add back into the system. The value should be in range 0 to 1.
- (void)setOptionalEnergyReturn:(AKConstant *)energyReturn;

/// Set an optional main resonant frequency
/// @param mainResonantFrequency The main resonant frequency. The default value is 2500.
- (void)setOptionalMainResonantFrequency:(AKConstant *)mainResonantFrequency;

/// Set an optional first resonant frequency
/// @param firstResonantFrequency The first resonant frequency. The default value is 5300.
- (void)setOptionalFirstResonantFrequency:(AKConstant *)firstResonantFrequency;

/// Set an optional second resonant frequency
/// @param secondResonantFrequency The second resonant frequency. The default value is 6500.
- (void)setOptionalSecondResonantFrequency:(AKConstant *)secondResonantFrequency;


@end