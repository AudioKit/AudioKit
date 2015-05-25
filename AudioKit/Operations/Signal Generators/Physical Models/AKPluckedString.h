//
//  AKPluckedString.h
//  AudioKit
//
//  Auto-generated on 2/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Physical model of the plucked string.

 A user can control the pluck point, the pickup point, the filter, and an additional audio signal used to excite the 'string'. Based on the Karplus-Strong algorithm.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKPluckedString : AKAudio
/// Instantiates the plucked string with all values
/// @param frequency Frequency of the string [Default Value: 440]
/// @param pluckPosition The point of pluck as a fraction of the way up the string (0 to 1). A pluck point of zero means no initial pluck. [Default Value: 0.01]
/// @param samplePosition Proportion of the way along the string to sample the output. Updated at Control-rate. [Default Value: 0.1]
/// @param reflectionCoefficient The coefficient of reflection, indicating the lossiness and the rate of decay. It must be strictly between 0 and 1 (it will complain about both 0 and 1). Updated at Control-rate. [Default Value: 0.1]
/// @param amplitude Amplitude of note. Updated at Control-rate. [Default Value: 1.0]
- (instancetype)initWithFrequency:(AKConstant *)frequency
                    pluckPosition:(AKConstant *)pluckPosition
                   samplePosition:(AKParameter *)samplePosition
            reflectionCoefficient:(AKParameter *)reflectionCoefficient
                        amplitude:(AKParameter *)amplitude;

/// Instantiates the plucked string with default values
- (instancetype)init;

/// Instantiates the plucked string with default values
+ (instancetype)pluck;

/// Instantiates the plucked string with default values
+ (instancetype)presetDefaultPluckedString;

/// Instantiates the plucked string with a quick decay
- (instancetype)initWithPresetDecayingPluckedString;

/// Instantiates the plucked string with a quick decay
+ (instancetype)presetDecayingPluckedString;

/// Instantiates the plucked string with a rounded sound
- (instancetype)initWithPresetRoundedPluckedString;

/// Instantiates the plucked string with a rounded sound
+ (instancetype)presetRoundedPluckedString;

/// Instantiates the plucked string with a 'snappy' sound
- (instancetype)initWithPresetSnappyPluckedString;

/// Instantiates the plucked string with a 'snappy' sound
+ (instancetype)presetSnappyPluckedString;


/// Frequency of the string [Default Value: 440]
@property (nonatomic) AKConstant *frequency;

/// Set an optional frequency
/// @param frequency Frequency of the string [Default Value: 440]
- (void)setOptionalFrequency:(AKConstant *)frequency;

/// The point of pluck as a fraction of the way up the string (0 to 1). A pluck point of zero means no initial pluck. [Default Value: 0.01]
@property (nonatomic) AKConstant *pluckPosition;

/// Set an optional pluck position
/// @param pluckPosition The point of pluck as a fraction of the way up the string (0 to 1). A pluck point of zero means no initial pluck. [Default Value: 0.01]
- (void)setOptionalPluckPosition:(AKConstant *)pluckPosition;

/// Proportion of the way along the string to sample the output. [Default Value: 0.1]
@property (nonatomic) AKParameter *samplePosition;

/// Set an optional sample position
/// @param samplePosition Proportion of the way along the string to sample the output. Updated at Control-rate. [Default Value: 0.1]
- (void)setOptionalSamplePosition:(AKParameter *)samplePosition;

/// The coefficient of reflection, indicating the lossiness and the rate of decay. It should be between 0 and 1. [Default Value: 0.1]
@property (nonatomic) AKParameter *reflectionCoefficient;

/// Set an optional reflection coefficient
/// @param reflectionCoefficient The coefficient of reflection, indicating the lossiness and the rate of decay. It must be strictly between 0 and 1 (it will complain about both 0 and 1). Updated at Control-rate. [Default Value: 0.1]
- (void)setOptionalReflectionCoefficient:(AKParameter *)reflectionCoefficient;

/// Amplitude of note. [Default Value: 1.0]
@property (nonatomic) AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude of note. Updated at Control-rate. [Default Value: 1.0]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;



@end
NS_ASSUME_NONNULL_END
