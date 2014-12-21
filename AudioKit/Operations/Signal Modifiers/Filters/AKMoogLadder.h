//
//  AKMoogLadder.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Moog ladder lowpass filter.

 Moog Ladder is an new digital implementation of the Moog ladder filter based on the work of Antti Huovilainen, described in the paper "Non-Linear Digital Implementation of the Moog Ladder Filter" (Proceedings of DaFX04, Univ of Napoli). This implementation is probably a more accurate digital representation of the original analogue filter.
 */

@interface AKMoogLadder : AKAudio
/// Instantiates the moog ladder with all values
/// @param audioSource Input Signal [Default Value: ]
/// @param cutoffFrequency Filter cutoff frequency [Default Value: 100]
/// @param resonance Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1. [Default Value: 0.5]
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                    cutoffFrequency:(AKControl *)cutoffFrequency
                          resonance:(AKControl *)resonance;

/// Instantiates the moog ladder with default values
/// @param audioSource Input Signal
- (instancetype)initWithAudioSource:(AKAudio *)audioSource;

/// Instantiates the moog ladder with default values
/// @param audioSource Input Signal
+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource;
/// Filter cutoff frequency [Default Value: 100]
@property AKControl *cutoffFrequency;

/// Set an optional cutoff frequency
/// @param cutoffFrequency Filter cutoff frequency [Default Value: 100]
- (void)setOptionalCutoffFrequency:(AKControl *)cutoffFrequency;
/// Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1. [Default Value: 0.5]
@property AKControl *resonance;

/// Set an optional resonance
/// @param resonance Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1. [Default Value: 0.5]
- (void)setOptionalResonance:(AKControl *)resonance;



@end
