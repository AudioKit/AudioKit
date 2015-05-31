//
//  AKResonantFilter.h
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A second-order resonant filter.
 
 This is a second-order filter defined by a center frequency which is the frequency position of the peak response, and a bandwidth which is the frequency difference between the upper and lower half-power points.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKResonantFilter : AKAudio
/// Instantiates the resonant filter with all values
/// @param input The input audio stream. 
/// @param centerFrequency Center frequency of the filter, or frequency position of the peak response. Updated at Control-rate. [Default Value: 1000]
/// @param bandwidth Bandwidth of the filter (the Hz difference between the upper and lower half-power points). Updated at Control-rate. [Default Value: 10]
- (instancetype)initWithInput:(AKParameter *)input
              centerFrequency:(AKParameter *)centerFrequency
                    bandwidth:(AKParameter *)bandwidth;

/// Instantiates the resonant filter with default values
/// @param input The input audio stream.
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the resonant filter with default values
/// @param input The input audio stream.
+ (instancetype)filterWithInput:(AKParameter *)input;

/// Instantiates the resonant filter with default values
/// @param input The input audio stream.
- (instancetype)initWithPresetDefaultFilterWithInput:(AKParameter *)input;

/// Instantiates the resonant filter with default values
/// @param input The input audio stream.
+ (instancetype)presetDefaultFilterWithInput:(AKParameter *)input;

/// Instantiates the resonant filter with a muffled sound
/// @param input The input audio stream.
- (instancetype)initWithPresetMuffledFilterWithInput:(AKParameter *)input;

/// Instantiates the resonant filter with a muffled sound
/// @param input The input audio stream.
+ (instancetype)presetMuffledFilterWithInput:(AKParameter *)input;

/// Instantiates the resonant filter with a high-treble sound
/// @param input The input audio stream.
- (instancetype)initWithPresetHighTrebleFilterWithInput:(AKParameter *)input;

/// Instantiates the resonant filter with a high-treble sound
/// @param input The input audio stream.
+ (instancetype)presetHighTrebleFilterWithInput:(AKParameter *)input;

/// Instantiates the resonant filter with a high-bass sound
/// @param input The input audio stream.
- (instancetype)initWithPresetHighBassFilterWithInput:(AKParameter *)input;

/// Instantiates the resonant filter with a high-bass sound
/// @param input The input audio stream.
+ (instancetype)presetHighBassFilterWithInput:(AKParameter *)input;


/// Center frequency of the filter, or frequency position of the peak response. [Default Value: 1000]
@property (nonatomic) AKParameter *centerFrequency;

/// Set an optional center frequency
/// @param centerFrequency Center frequency of the filter, or frequency position of the peak response. Updated at Control-rate. [Default Value: 1000]
- (void)setOptionalCenterFrequency:(AKParameter *)centerFrequency;

/// Bandwidth of the filter (the Hz difference between the upper and lower half-power points). [Default Value: 10]
@property (nonatomic) AKParameter *bandwidth;

/// Set an optional bandwidth
/// @param bandwidth Bandwidth of the filter (the Hz difference between the upper and lower half-power points). Updated at Control-rate. [Default Value: 10]
- (void)setOptionalBandwidth:(AKParameter *)bandwidth;



@end
NS_ASSUME_NONNULL_END
