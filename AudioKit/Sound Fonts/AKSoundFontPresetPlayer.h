//
//  AKSoundFontPresetPlayer.h
//  AudioKit
//
//  Auto-generated on 6/12/15. Customized by Aurelius Prochazka on 6/30/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKParameter+Operation.h"
#import "AKStereoAudio.h"

@class AKSoundFontPreset;

/** Plays a SoundFont2 (SF2) sample preset, generating a stereo sound with cubic interpolation.
 
 
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKSoundFontPresetPlayer : AKStereoAudio
/// Instantiates the sound font player with all values
/// @param soundFontPreset Sound Font Preset
/// @param noteNumber MIDI Note Number. [Default Value: 60]
/// @param velocity Velocity from zero to 1. [Default Value: 1]
/// @param frequencyMultiplier Frequency Multiplier. [Default Value: 1]
/// @param amplitude Amplitude correction (different from velocity). [Default Value: 1]
- (instancetype)initWithSoundFontPreset:(AKSoundFontPreset *)soundFontPreset
                             noteNumber:(AKConstant *)noteNumber
                               velocity:(AKConstant *)velocity
                    frequencyMultiplier:(AKParameter *)frequencyMultiplier
                              amplitude:(AKParameter *)amplitude;

/// Instantiates the sound font player with default values
/// @param soundFontPreset Sound Font Preset
- (instancetype)initWithSoundFontPreset:(AKSoundFontPreset *)soundFontPreset;

/// Instantiates the sound font player with default values
/// @param soundFontPreset Sound Font Preset
+ (instancetype)playerWithSoundFontPreset:(AKSoundFontPreset *)soundFontPreset;


/// MIDI Note Number. [Default Value: 60]
@property (nonatomic) AKConstant *noteNumber;

/// Set an optional note number
/// @param noteNumber MIDI Note Number. [Default Value: 60]
- (void)setOptionalNoteNumber:(AKConstant *)noteNumber;

/// Velocity from zero to 1. [Default Value: 1]
@property (nonatomic) AKConstant *velocity;

/// Set an optional velocity
/// @param velocity Velocity from zero to 1. [Default Value: 1]
- (void)setOptionalVelocity:(AKConstant *)velocity;

/// Frequency Multiplier. [Default Value: 1]
@property (nonatomic) AKParameter *frequencyMultiplier;

/// Set an optional frequency multiplier
/// @param frequencyMultiplier Frequency Multiplier. [Default Value: 1]
- (void)setOptionalFrequencyMultiplier:(AKParameter *)frequencyMultiplier;

/// Amplitude correction (different from velocity). [Default Value: 1]
@property (nonatomic) AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude correction (different from velocity). [Default Value: 1]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;



@end
NS_ASSUME_NONNULL_END

