//
//  AKBowedString.h
//  AudioKit
//
//  Auto-generated on 3/2/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Creates a tone similar to a bowed string.

 Audio output is a tone similar to a bowed string, using a physical model developed from Perry Cook, but recoded for Csound.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKBowedString : AKAudio
/// Instantiates the bowed string with all values
/// @param frequency Frequency of the note played, note that this will be lowest allowable frequency unless the optional minimum frequency is set. Updated at Control-rate. [Default Value: 110]
/// @param amplitude Amplitude of the note played. Updated at Control-rate. [Default Value: 1]
/// @param pressure Parameter controlling the pressure of the bow on the string. Values should be about 3. The useful range is approximately 1 to 5. Updated at Control-rate. [Default Value: 3]
/// @param position Position of the bow along the string. Usual playing is about 0.127236. The suggested range is 0.025 to 0.23. Updated at Control-rate. [Default Value: 0.127236]
/// @param vibratoShape Table shape of vibrato, usually a sine table. [Default Value: sine]
/// @param vibratoFrequency Frequency of vibrato in Hertz. Suggested range is 0 to 12. Updated at Control-rate. [Default Value: 0]
/// @param vibratoAmplitude Amplitude of the vibrato. Updated at Control-rate. [Default Value: 0]
/// @param minimumFrequency Lowest frequency at which the instrument will play.  [Default Value: 0]
- (instancetype)initWithFrequency:(AKParameter *)frequency
                        amplitude:(AKParameter *)amplitude
                         pressure:(AKParameter *)pressure
                         position:(AKParameter *)position
                     vibratoShape:(AKTable *)vibratoShape
                 vibratoFrequency:(AKParameter *)vibratoFrequency
                 vibratoAmplitude:(AKParameter *)vibratoAmplitude
                 minimumFrequency:(AKConstant *)minimumFrequency;

/// Instantiates the bowed string with default values
- (instancetype)init;

/// Instantiates the bowed string with default values
+ (instancetype)bowedString;

/// Instantiates the bowed string with default values
+ (instancetype)presetDefaultBowedString;

/// Instantiates the bowed string with a 'whistling' sound
- (instancetype)initWithPresetWhistlingBowedString;

/// Instantiates the bowed string with a 'whistling' sound
+ (instancetype)presetWhistlingBowedString;

/// Instantiates the bowed string with a sound like a train whistle
- (instancetype)initWithPresetTrainWhislteBowedString;

/// Instantiates the bowed string with a sound like a train whistle
+ (instancetype)presetTrainWhislteBowedString;

/// Instantiates the bowed string with a sound like a ship horn
- (instancetype)initWithPresetFogHornBowedString;

/// Instantiates the bowed string with a sound like a ship horn
+ (instancetype)presetFogHornBowedString;

/// Instantiates the bowed string with a cello sound
- (instancetype)initWithPresetCelloBowedString;

/// Instantiates the bowed string with a cello sound
+ (instancetype)presetCelloBowedString;

/// Instantiates the bowed string with a guitar feedback-esque sound
- (instancetype)initWithPresetFeedbackBowedString;

/// Instantiates the bowed string with a guitar feedback-esque sound
+ (instancetype)presetFeedbackBowedString;


/// Frequency of the note played, note that this will be lowest allowable frequency unless the optional minimum frequency is set. [Default Value: 110]
@property (nonatomic) AKParameter *frequency;

/// Set an optional frequency
/// @param frequency Frequency of the note played, note that this will be lowest allowable frequency unless the optional minimum frequency is set. Updated at Control-rate. [Default Value: 110]
- (void)setOptionalFrequency:(AKParameter *)frequency;

/// Amplitude of the note played. [Default Value: 1]
@property (nonatomic) AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude of the note played. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;

/// Parameter controlling the pressure of the bow on the string. Values should be about 3. The useful range is approximately 1 to 5. [Default Value: 3]
@property (nonatomic) AKParameter *pressure;

/// Set an optional pressure
/// @param pressure Parameter controlling the pressure of the bow on the string. Values should be about 3. The useful range is approximately 1 to 5. Updated at Control-rate. [Default Value: 3]
- (void)setOptionalPressure:(AKParameter *)pressure;

/// Position of the bow along the string. Usual playing is about 0.127236. The suggested range is 0.025 to 0.23. [Default Value: 0.127236]
@property (nonatomic) AKParameter *position;

/// Set an optional position
/// @param position Position of the bow along the string. Usual playing is about 0.127236. The suggested range is 0.025 to 0.23. Updated at Control-rate. [Default Value: 0.127236]
- (void)setOptionalPosition:(AKParameter *)position;

/// Table shape of vibrato, usually a sine table. [Default Value: sine]
@property (nonatomic) AKTable *vibratoShape;

/// Set an optional vibrato shape
/// @param vibratoShape Table shape of vibrato, usually a sine table. [Default Value: sine]
- (void)setOptionalVibratoShape:(AKTable *)vibratoShape;

/// Frequency of vibrato in Hertz. Suggested range is 0 to 12. [Default Value: 0]
@property (nonatomic) AKParameter *vibratoFrequency;

/// Set an optional vibrato frequency
/// @param vibratoFrequency Frequency of vibrato in Hertz. Suggested range is 0 to 12. Updated at Control-rate. [Default Value: 0]
- (void)setOptionalVibratoFrequency:(AKParameter *)vibratoFrequency;

/// Amplitude of the vibrato. [Default Value: 0]
@property (nonatomic) AKParameter *vibratoAmplitude;

/// Set an optional vibrato amplitude
/// @param vibratoAmplitude Amplitude of the vibrato. Updated at Control-rate. [Default Value: 0]
- (void)setOptionalVibratoAmplitude:(AKParameter *)vibratoAmplitude;

/// Lowest frequency at which the instrument will play.  [Default Value: 0]
@property (nonatomic) AKConstant *minimumFrequency;

/// Set an optional minimum frequency
/// @param minimumFrequency Lowest frequency at which the instrument will play.  [Default Value: 0]
- (void)setOptionalMinimumFrequency:(AKConstant *)minimumFrequency;



@end
NS_ASSUME_NONNULL_END
