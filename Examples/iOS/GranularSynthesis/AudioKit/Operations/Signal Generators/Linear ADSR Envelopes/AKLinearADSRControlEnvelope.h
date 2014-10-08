//
//  AKLinearADSRControlEnvelope.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/31/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** Calculates the classical ADSR envelope using linear segments.
 
 The envelope generated is the range 0 to 1 and may need to be scaled further, depending on the amplitude required. The length of the sustain is calculated from the length of the note. This means this operation is not suitable for use with MIDI events.
 */

@interface AKLinearADSRControlEnvelope : AKControl

/// Instantiates the linear adsr control envelope
/// @param attackDuration Duration of attack phase
/// @param decayDuration Duration of decay
/// @param sustainLevel Level for sustain phase
/// @param releaseDuration Duration of release phase
- (instancetype)initWithAttackDuration:(AKConstant *)attackDuration
                         decayDuration:(AKConstant *)decayDuration
                          sustainLevel:(AKConstant *)sustainLevel
                       releaseDuration:(AKConstant *)releaseDuration;


/// Set an optional delay
/// @param delay Period of zero before the envelope starts
- (void)setOptionalDelay:(AKConstant *)delay;


@end