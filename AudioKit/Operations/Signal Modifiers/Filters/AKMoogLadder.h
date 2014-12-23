//
//  AKMoogLadder.h
//  AudioKit
//
//  Auto-generated on 12/23/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Moog ladder lowpass filter.

 Moog Ladder is an new digital implementation of the Moog ladder filter based on the work of Antti Huovilainen, described in the paper "Non-Linear Digital Implementation of the Moog Ladder Filter" (Proceedings of DaFX04, Univ of Napoli). This implementation is probably a more accurate digital representation of the original analogue filter.
 */

@interface AKMoogLadder : AKAudio
/// Instantiates the moog ladder with all values
/// @param audioSource Input Signal [Default Value: ]
/// @param cutoffFrequency Filter cutoff frequency Updated at Control-rate. [Default Value: 100]
/// @param resonance Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1. Updated at Control-rate. [Default Value: 0.5]
- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                    cutoffFrequency:(AKParameter *)cutoffFrequency
                          resonance:(AKParameter *)resonance;

/// Instantiates the moog ladder with default values
/// @param audioSource Input Signal
- (instancetype)initWithAudioSource:(AKParameter *)audioSource;

/// Instantiates the moog ladder with default values
/// @param audioSource Input Signal
+ (instancetype)audioWithAudioSource:(AKParameter *)audioSource;

/// Filter cutoff frequency [Default Value: 100]
@property AKParameter *cutoffFrequency;

/// Set an optional cutoff frequency
/// @param cutoffFrequency Filter cutoff frequency Updated at Control-rate. [Default Value: 100]
- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency;

/// Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1. [Default Value: 0.5]
@property AKParameter *resonance;

/// Set an optional resonance
/// @param resonance Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1. Updated at Control-rate. [Default Value: 0.5]
- (void)setOptionalResonance:(AKParameter *)resonance;



@end
