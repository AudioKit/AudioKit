//
//  AKMoogLadder.h
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Moog ladder lowpass filter.

 Moog Ladder is an new digital implementation of the Moog ladder filter based on the work of Antti Huovilainen, described in the paper "Non-Linear Digital Implementation of the Moog Ladder Filter" (Proceedings of DaFX04, Univ of Napoli). This implementation is probably a more accurate digital representation of the original analogue filter.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKMoogLadder : AKAudio
/// Instantiates the moog ladder with all values
/// @param input Input signal 
/// @param cutoffFrequency Filter cutoff frequency Updated at Control-rate. [Default Value: 100]
/// @param resonance Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1. Updated at Control-rate. [Default Value: 0.5]
- (instancetype)initWithInput:(AKParameter *)input
              cutoffFrequency:(AKParameter *)cutoffFrequency
                    resonance:(AKParameter *)resonance;

/// Instantiates the moog ladder with default values
/// @param input Input signal
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the moog ladder with default values
/// @param input Input signal
+ (instancetype)filterWithInput:(AKParameter *)input;

/// Instantiates the moog ladder with default values
/// @param input Input signal
- (instancetype)initWithPresetDefaultFilterWithInput:(AKParameter *)input;

/// Instantiates the moog ladder with default values
/// @param input Input signal
+ (instancetype)presetDefaultFilterWithInput:(AKParameter *)input;

/// Instantiates the moog ladder with an 'underwater' sound
/// @param input Input signal
- (instancetype)initWithPresetUnderwaterFilterWithInput:(AKParameter *)input;

/// Instantiates the moog ladder with an 'underwater' sound
/// @param input Input signal
+ (instancetype)presetUnderwaterFilterWithInput:(AKParameter *)input;

/// Instantiates the moog ladder with an bass-heavy sound
/// @param input Input signal
- (instancetype)initWithPresetBassHeavyFilterWithInput:(AKParameter *)input;

/// Instantiates the moog ladder with an bass-heavy sound
/// @param input Input signal
+ (instancetype)presetBassHeavyFilterWithInput:(AKParameter *)input;

/// Filter cutoff frequency [Default Value: 100]
@property (nonatomic) AKParameter *cutoffFrequency;

/// Set an optional cutoff frequency
/// @param cutoffFrequency Filter cutoff frequency Updated at Control-rate. [Default Value: 100]
- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency;

/// Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1. [Default Value: 0.5]
@property (nonatomic) AKParameter *resonance;

/// Set an optional resonance
/// @param resonance Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1. Updated at Control-rate. [Default Value: 0.5]
- (void)setOptionalResonance:(AKParameter *)resonance;



@end
NS_ASSUME_NONNULL_END
