//
//  AKGuiro.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/4/12.
//  Manually modified by Aurelius Prochazka on 11/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Semi-physical model of a guiro sound.
 
 This is one of the PhISEM percussion opcodes. PhISEM (Physically Informed Stochastic Event Modeling) is an algorithmic approach for simulating collisions of multiple independent sound producing objects.
 */

@interface AKGuiro : AKAudio

/// Instantiates the guiro
/// @param duration Period of time over which all sound is stopped
/// @param amplitude Amplitude of output. Since these instruments are stochastic this is only an approximation.
- (instancetype)initWithDuration:(AKConstant *)duration
                       amplitude:(AKControl *)amplitude;


/// Set an optional count
/// @param count The number of beads, teeth, bells, timbrels, etc. The default value is 128.
- (void)setOptionalCount:(AKConstant *)count;

/// Set an optional energy return
/// @param energyReturn Amount of energy to add back into the system. The value should be in range 0 to 1.
- (void)setOptionalEnergyReturn:(AKConstant *)energyReturn;

/// Set an optional main resonant frequency
/// @param mainResonantFrequency The main resonant frequency. The default value is 2500.
- (void)setOptionalMainResonantFrequency:(AKConstant *)mainResonantFrequency;

/// Set an optional first resonant frequency
/// @param firstResonantFrequency The first resonant frequency. The default value is 4000.
- (void)setOptionalFirstResonantFrequency:(AKConstant *)firstResonantFrequency;

@end