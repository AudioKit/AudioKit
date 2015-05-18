//
//  AKMandolin.h
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** An emulation of a mandolin.

 A mandolin emulation with amplitude, frequency, tuning, gain and mandolin size parameters.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKMandolin : AKAudio
/// Instantiates the mandolin with all values
/// @param bodySize The size of the body of the mandolin. Range 0 (small) to 1 (large). Updated at Control-rate. [Default Value: 0.5]
/// @param frequency Frequency of note played. Updated at Control-rate. [Default Value: 220]
/// @param amplitude Amplitude of note. Updated at Control-rate. [Default Value: 1]
/// @param pairedStringDetuning The proportional detuning between the two strings. Suggested range 0.9 to 1. Updated at Control-rate. [Default Value: 1]
/// @param pluckPosition The pluck position, in range 0 to 1. [Default Value: 0.4]
/// @param loopGain The loop gain of the model, in the range 0.97 to 1. Updated at Control-rate. [Default Value: 0.99]
- (instancetype)initWithBodySize:(AKParameter *)bodySize
                       frequency:(AKParameter *)frequency
                       amplitude:(AKParameter *)amplitude
            pairedStringDetuning:(AKParameter *)pairedStringDetuning
                   pluckPosition:(AKConstant *)pluckPosition
                        loopGain:(AKParameter *)loopGain;

/// Instantiates the mandolin with default values
- (instancetype)init;

/// Instantiates the mandolin with default values
+ (instancetype)mandolin;

/// Instantiates the mandolin with default values
+ (instancetype)presetDefaultMandolin;

/// Instantiates the mandolin with default detuned values
- (instancetype)initWithPresetDetunedMandolin;

/// Instantiates the mandolin with default detuned values
+ (instancetype)presetDetunedMandolin;

/// Instantiates the mandolin with default small-bodied values
- (instancetype)initWithPresetSmallMandolin;

/// Instantiates the mandolin with default small-bodied values
+ (instancetype)presetSmallMandolin;


/// The size of the body of the mandolin. Range 0 (small) to 1 (large). [Default Value: 0.5]
@property (nonatomic) AKParameter *bodySize;

/// Set an optional body size
/// @param bodySize The size of the body of the mandolin. Range 0 (small) to 1 (large). Updated at Control-rate. [Default Value: 0.5]
- (void)setOptionalBodySize:(AKParameter *)bodySize;

/// Frequency of note played. [Default Value: 220]
@property (nonatomic) AKParameter *frequency;

/// Set an optional frequency
/// @param frequency Frequency of note played. Updated at Control-rate. [Default Value: 220]
- (void)setOptionalFrequency:(AKParameter *)frequency;

/// Amplitude of note. [Default Value: 1]
@property (nonatomic) AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude of note. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;

/// The proportional detuning between the two strings. Suggested range 0.9 to 1. [Default Value: 1]
@property (nonatomic) AKParameter *pairedStringDetuning;

/// Set an optional paired string detuning
/// @param pairedStringDetuning The proportional detuning between the two strings. Suggested range 0.9 to 1. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalPairedStringDetuning:(AKParameter *)pairedStringDetuning;

/// The pluck position, in range 0 to 1. [Default Value: 0.4]
@property (nonatomic) AKConstant *pluckPosition;

/// Set an optional pluck position
/// @param pluckPosition The pluck position, in range 0 to 1. [Default Value: 0.4]
- (void)setOptionalPluckPosition:(AKConstant *)pluckPosition;

/// The loop gain of the model, in the range 0.97 to 1. [Default Value: 0.99]
@property (nonatomic) AKParameter *loopGain;

/// Set an optional loop gain
/// @param loopGain The loop gain of the model, in the range 0.97 to 1. Updated at Control-rate. [Default Value: 0.99]
- (void)setOptionalLoopGain:(AKParameter *)loopGain;



@end
NS_ASSUME_NONNULL_END
