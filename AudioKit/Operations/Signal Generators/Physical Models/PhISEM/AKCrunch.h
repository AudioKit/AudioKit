//
//  AKCrunch.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Semi-physical model of a crunch sound.
 
 This one of the PhISEM percussion opcodes. PhISEM (Physically Informed Stochastic Event Modeling) is an algorithmic approach for simulating collisions of multiple independent sound producing objects.
 */

@interface AKCrunch : AKAudio

/// Instantiates the crunch
/// @param duration Period of time over which all sound is stopped.
/// @param amplitude Amplitude of output. As these instruments are stochastic this is only a approximation.
- (instancetype)initWithDuration:(AKConstant *)duration
                       amplitude:(AKConstant *)amplitude;


/// Set an optional count
/// @param count The number of beads, teeth, bells, timbrels, etc. The default value is 7.
- (void)setOptionalCount:(AKConstant *)count;

/// Set an optional damping factor
/// @param dampingFactor The damping factor, as part of this equation "damping = 0.998 + (dampingFactor * 0.002)" The default damping is 0.99806 which means that the default value of dampingFactor is 0.03. The maximum damping is 1.0 (no damping). This means the maximum value for dampingFactor is 1.0. The recommended range for dampingFactor is usually below 75% of the maximum value.
- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor;


@end