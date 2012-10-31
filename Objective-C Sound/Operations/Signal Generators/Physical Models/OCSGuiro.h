//
//  OCSGuiro.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** Semi-physical model of a guiro sound.
 
 This is one of the PhISEM percussion opcodes. PhISEM (Physically Informed Stochastic Event Modeling) is an algorithmic approach for simulating collisions of multiple independent sound producing objects.
 */

@interface OCSGuiro : OCSAudio

/// Instantiates the guiro
/// @param duration Period of time over which all sound is stopped
/// @param amplitude Amplitude of output. Since these instruments are stochastic this is only an approximation.
- (id)initWithDuration:(OCSConstant *)duration
             amplitude:(OCSControl *)amplitude;


/// Set an optional count
/// @param count The number of beads, teeth, bells, timbrels, etc. The default value is 128.
- (void)setOptionalCount:(OCSConstant *)count;

/// Set an optional energy return
/// @param energyReturn Amount of energy to add back into the system. The value should be in range 0 to 1.
- (void)setOptionalEnergyReturn:(OCSConstant *)energyReturn;

/// Set an optional main resonant frequency
/// @param mainResonantFrequency The main resonant frequency. The default value is 2500.
- (void)setOptionalMainResonantFrequency:(OCSConstant *)mainResonantFrequency;

/// Set an optional first resonant frequency
/// @param firstResonantFrequency The first resonant frequency. The default value is 4000.
- (void)setOptionalFirstResonantFrequency:(OCSConstant *)firstResonantFrequency;

@end