//
//  AKFlute.h
//  AudioKit
//
//  Auto-generated on 5/25/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A physical model of a flute

 Audio output is a tone similar to a flute, using a physical model developed from Perry Cook
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKFlute : AKAudio
/// Instantiates the flute with all values
/// @param frequency Frequency of the note. Updated at Control-rate. [Default Value: 440]
/// @param attackTime Time in seconds to reach full blowing pressure. [Default Value: 0.1]
/// @param releaseTime Time in seconds taken to stop blowing. [Default Value: 0.1]
/// @param airJetPressure a parameter controlling the air jet. Values should be positive, and the useful range is approximately 0.08 to 0.56. Updated at Control-rate. [Default Value: 0.2]
/// @param airJetReflection Amount of reflection in the breath jet that powers the flute. [Default Value: 0.5]
/// @param reflectionCoefficient Reflection coefficient of the breath jet. [Default Value: 0.5]
/// @param noiseAmplitude Amplitude of the noise component, about 0 to 0.5 Updated at Control-rate. [Default Value: 0.15]
/// @param amplitude Amplitude of the note, up to but not including 1. Updated at Control-rate. [Default Value: 0.5]
/// @param vibratoShape Table defining the shape of the vibrato. [Default Value: sine]
/// @param vibratoAmplitude Amplitude of the vibrato. Updated at Control-rate. [Default Value: 0]
/// @param vibratoFrequency Frequency of vibrato in Hertz. Suggested range is 0 to 12 Updated at Control-rate. [Default Value: 0]
- (instancetype)initWithFrequency:(AKParameter *)frequency
                       attackTime:(AKConstant *)attackTime
                      releaseTime:(AKConstant *)releaseTime
                   airJetPressure:(AKParameter *)airJetPressure
                 airJetReflection:(AKConstant *)airJetReflection
            reflectionCoefficient:(AKConstant *)reflectionCoefficient
                   noiseAmplitude:(AKParameter *)noiseAmplitude
                        amplitude:(AKParameter *)amplitude
                     vibratoShape:(AKTable *)vibratoShape
                 vibratoAmplitude:(AKParameter *)vibratoAmplitude
                 vibratoFrequency:(AKParameter *)vibratoFrequency;

/// Instantiates the flute with default values
- (instancetype)init;

/// Instantiates the flute with default values
+ (instancetype)flute;

/// Instantiates the flute with default values
+ (instancetype)presetDefaultFlute;

/// Instantiates the flute with a sound resembling microphone feedback
- (instancetype)initWithPresetMicFeedbackFlute;

/// Instantiates the flute with a sound resembling microphone feedback
+ (instancetype)presetMicFeedbackFlute;

/// Instantiates the flute with a sound resembling a large ship horn
- (instancetype)initWithPresetShipsHornFlute;

/// Instantiates the flute with a sound resembling a large ship horn
+ (instancetype)presetShipsHornFlute;

/// Instantiates the flute with a sci-fi type sound
- (instancetype)initWithPresetSciFiNoiseFlute;

/// Instantiates the flute with a sci-fi type sound
+ (instancetype)presetSciFiNoiseFlute;

/// Instantiates the flute with a screaming space sound
- (instancetype)initWithPresetScreamingFlute;

/// Instantiates the flute with a screaming space sound
+ (instancetype)presetScreamingFlute;

/// Frequency of the note. [Default Value: 440]
@property (nonatomic) AKParameter *frequency;

/// Set an optional frequency
/// @param frequency Frequency of the note. Updated at Control-rate. [Default Value: 440]
- (void)setOptionalFrequency:(AKParameter *)frequency;

/// Time in seconds to reach full blowing pressure. [Default Value: 0.1]
@property (nonatomic) AKConstant *attackTime;

/// Set an optional attack time
/// @param attackTime Time in seconds to reach full blowing pressure. [Default Value: 0.1]
- (void)setOptionalAttackTime:(AKConstant *)attackTime;

/// Time in seconds taken to stop blowing. [Default Value: 0.1]
@property (nonatomic) AKConstant *releaseTime;

/// Set an optional release time
/// @param releaseTime Time in seconds taken to stop blowing. [Default Value: 0.1]
- (void)setOptionalReleaseTime:(AKConstant *)releaseTime;

/// a parameter controlling the air jet. Values should be positive, and the useful range is approximately 0.08 to 0.56. [Default Value: 0.2]
@property (nonatomic) AKParameter *airJetPressure;

/// Set an optional air jet pressure
/// @param airJetPressure a parameter controlling the air jet. Values should be positive, and the useful range is approximately 0.08 to 0.56. Updated at Control-rate. [Default Value: 0.2]
- (void)setOptionalAirJetPressure:(AKParameter *)airJetPressure;

/// Amount of reflection in the breath jet that powers the flute. [Default Value: 0.5]
@property (nonatomic) AKConstant *airJetReflection;

/// Set an optional air jet reflection
/// @param airJetReflection Amount of reflection in the breath jet that powers the flute. [Default Value: 0.5]
- (void)setOptionalAirJetReflection:(AKConstant *)airJetReflection;

/// Reflection coefficient of the breath jet. [Default Value: 0.5]
@property (nonatomic) AKConstant *reflectionCoefficient;

/// Set an optional reflection coefficient
/// @param reflectionCoefficient Reflection coefficient of the breath jet. [Default Value: 0.5]
- (void)setOptionalReflectionCoefficient:(AKConstant *)reflectionCoefficient;

/// Amplitude of the noise component, about 0 to 0.5 [Default Value: 0.15]
@property (nonatomic) AKParameter *noiseAmplitude;

/// Set an optional noise amplitude
/// @param noiseAmplitude Amplitude of the noise component, about 0 to 0.5 Updated at Control-rate. [Default Value: 0.15]
- (void)setOptionalNoiseAmplitude:(AKParameter *)noiseAmplitude;

/// Amplitude of the note, up to but not including 1. [Default Value: 0.5]
@property (nonatomic) AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude of the note, up to but not including 1. Updated at Control-rate. [Default Value: 0.5]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;

/// Table defining the shape of the vibrato. [Default Value: sine]
@property (nonatomic) AKTable *vibratoShape;

/// Set an optional vibrato shape
/// @param vibratoShape Table defining the shape of the vibrato. [Default Value: sine]
- (void)setOptionalVibratoShape:(AKTable *)vibratoShape;

/// Amplitude of the vibrato. [Default Value: 0]
@property (nonatomic) AKParameter *vibratoAmplitude;

/// Set an optional vibrato amplitude
/// @param vibratoAmplitude Amplitude of the vibrato. Updated at Control-rate. [Default Value: 0]
- (void)setOptionalVibratoAmplitude:(AKParameter *)vibratoAmplitude;

/// Frequency of vibrato in Hertz. Suggested range is 0 to 12 [Default Value: 0]
@property (nonatomic) AKParameter *vibratoFrequency;

/// Set an optional vibrato frequency
/// @param vibratoFrequency Frequency of vibrato in Hertz. Suggested range is 0 to 12 Updated at Control-rate. [Default Value: 0]
- (void)setOptionalVibratoFrequency:(AKParameter *)vibratoFrequency;



@end
NS_ASSUME_NONNULL_END

