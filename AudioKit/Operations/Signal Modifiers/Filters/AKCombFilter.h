//
//  AKCombFilter.h
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Reverberates an input signal with a “colored” frequency response.

 This filter reiterates input with an echo density determined by loopDuration. The attenuation rate is independent and is determined by reverbDuration, the reverberation duration (defined as the time in seconds for a signal to decay to 1/1000, or 60dB down from its original amplitude). Output from a comb filter will appear only after loopDuration seconds.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKCombFilter : AKAudio
/// Instantiates the comb filter with all values
/// @param input Input signal, usually audio. 
/// @param reverbDuration The time in seconds for a signal to decay to 1/1000, or 60dB from its original amplitude. Updated at Control-rate. [Default Value: 1]
/// @param loopDuration Determines frequency response curve, loopDuration * sr/2 peaks spaced evenly between 0 and sr/2. [Default Value: 0.1]
- (instancetype)initWithInput:(AKParameter *)input
               reverbDuration:(AKParameter *)reverbDuration
                 loopDuration:(AKConstant *)loopDuration;

/// Instantiates the comb filter with default values
/// @param input Input signal, usually audio.
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the comb filter with default values
/// @param input Input signal, usually audio.
+ (instancetype)filterWithInput:(AKParameter *)input;

/// Instantiates the comb filter with default values
/// @param input Input signal, usually audio.
- (instancetype)initWithPresetDefaultFilterWithInput:(AKParameter *)input;

/// Instantiates the comb filter with default values
/// @param input Input signal, usually audio.
+ (instancetype)presetDefaultFilterWithInput:(AKParameter *)input;

/// Instantiates the comb filter with a 'springy' sound
/// @param input Input signal, usually audio.
- (instancetype)initWithPresetSpringyFilterWithInput:(AKParameter *)input;

/// Instantiates the comb filter with a 'springy' sound
/// @param input Input signal, usually audio.
+ (instancetype)presetSpringFilterWithInput:(AKParameter *)input;

/// Instantiates the comb filter with a 'shuffling' sound
/// @param input Input signal, usually audio.
- (instancetype)initWithPresetShuffleFilterWithInput:(AKParameter *)input;

/// Instantiates the comb filter with a 'shuffling' sound
/// @param input Input signal, usually audio.
+ (instancetype)presetShuffleFilterWithInput:(AKParameter *)input;

/// The time in seconds for a signal to decay to 1/1000, or 60dB from its original amplitude. [Default Value: 1]
@property (nonatomic) AKParameter *reverbDuration;

/// Set an optional reverb duration
/// @param reverbDuration The time in seconds for a signal to decay to 1/1000, or 60dB from its original amplitude. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalReverbDuration:(AKParameter *)reverbDuration;

/// Determines frequency response curve, loopDuration * sr/2 peaks spaced evenly between 0 and sr/2. [Default Value: 0.1]
@property (nonatomic) AKConstant *loopDuration;

/// Set an optional loop duration
/// @param loopDuration Determines frequency response curve, loopDuration * sr/2 peaks spaced evenly between 0 and sr/2. [Default Value: 0.1]
- (void)setOptionalLoopDuration:(AKConstant *)loopDuration;



@end
NS_ASSUME_NONNULL_END
