//
//  AKSoundFontPlayer.h
//  AudioKit
//
//  Auto-generated on 6/12/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKStereoAudio.h"
#import "AKSoundFont.h"
#import "AKParameter+Operation.h"

/** Plays a SoundFont2 (SF2) sample preset, generating a stereo sound with cubic interpolation.
 
 
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKSoundFontPlayer : AKStereoAudio
/// Instantiates the sound font player with all values
/// @param noteNumber MIDI Note Number. [Default Value: 60]
/// @param velocity Velocity from zero to 1. [Default Value: 1]
/// @param frequencyMultiplier Frequency Multiplier. [Default Value: 1]
/// @param amplitude Amplitude correction (different from velocity). [Default Value: 1]
- (instancetype)initWithSoundFont:(AKSoundFont *)soundFont
                       noteNumber:(AKConstant *)noteNumber
                         velocity:(AKConstant *)velocity
              frequencyMultiplier:(AKParameter *)frequencyMultiplier
                        amplitude:(AKParameter *)amplitude;

/// Instantiates the sound font player with default values
- (instancetype)initWithSoundFont:(AKSoundFont *)soundFont;

/// Instantiates the sound font player with default values
+ (instancetype)playerWithSoundFont:(AKSoundFont *)soundFont;


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

