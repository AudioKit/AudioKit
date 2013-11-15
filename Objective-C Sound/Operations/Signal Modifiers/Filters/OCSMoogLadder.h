//
//  OCSMoogLadder.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** Moog ladder lowpass filter.
 
 Moog Ladder is an new digital implementation of the Moog ladder filter based on the work of Antti Huovilainen, described in the paper "Non-Linear Digital Implementation of the Moog Ladder Filter" (Proceedings of DaFX04, Univ of Napoli). This implementation is probably a more accurate digital representation of the original analogue filter.
 */

@interface OCSMoogLadder : OCSAudio

/// Instantiates the moog ladder
/// @param audioSource Input Signal
/// @param cutoffFrequency Filter cutoff frequency
/// @param resonance Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1.
- (instancetype)initWithAudioSource:(OCSAudio *)audioSource
          cutoffFrequency:(OCSControl *)cutoffFrequency
                resonance:(OCSControl *)resonance;

@end