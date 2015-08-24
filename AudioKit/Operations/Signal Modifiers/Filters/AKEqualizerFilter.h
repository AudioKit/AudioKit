//
//  AKEqualizerFilter.h
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Second-order tunable equalisation filter based on Regalia and Mitra design.

 Provides a peak/notch filter for building parametric/graphic equalisers.
The amplitude response for this filter will be flat (=1) for gain=1. With gain bigger than 1, there will be a peak at the center frequency, whose width is given by the bandwidth parameter, but outside this band, the response will tend towards 1. Conversely, if gain is smaller than 1, a notch will be created around the CF.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKEqualizerFilter : AKAudio
/// Instantiates the equalizer filter with all values
/// @param input Input signal. 
/// @param centerFrequency Filter center frequency in Hz. Updated at Control-rate. [Default Value: 1000]
/// @param bandwidth Peak/notch bandwidth in Hz. Updated at Control-rate. [Default Value: 100]
/// @param gain Peak/notch gain. Updated at Control-rate. [Default Value: 10]
- (instancetype)initWithInput:(AKParameter *)input
              centerFrequency:(AKParameter *)centerFrequency
                    bandwidth:(AKParameter *)bandwidth
                         gain:(AKParameter *)gain;

/// Instantiates the equalizer filter with default values
/// @param input Input signal.
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the equalizer filter with default values
/// @param input Input signal.
+ (instancetype)filterWithInput:(AKParameter *)input;

/// Instantiates the equalizer filter with default values
/// @param input Input signal.
- (instancetype)initWithPresetDefaultFilterWithInput:(AKParameter *)input;

/// Instantiates the equalizer filter with default values
/// @param input Input signal.
+ (instancetype)presetDefaultFilterWithInput:(AKParameter *)input;

/// Instantiates the equalizer filter with a narrow, low frequency notch setting
/// @param input Input signal.
- (instancetype)initWithPresetNarrowLowFrequencyNotchFilterWithInput:(AKParameter *)input;

/// Instantiates the equalizer filter with a narrow, low frequency notch setting
/// @param input Input signal.
+ (instancetype)presetNarrowLowFrequencyNotchFilterWithInput:(AKParameter *)input;

/// Instantiates the equalizer filter with a narrow, high frequency notch setting
/// @param input Input signal.
- (instancetype)initWithPresetNarrowHighFrequencyNotchFilterWithInput:(AKParameter *)input;

/// Instantiates the equalizer filter with a narrow, high frequency notch setting
/// @param input Input signal.
+ (instancetype)presetNarrowHighFrequencyNotchFilterWithInput:(AKParameter *)input;

/// Instantiates the equalizer filter with a wide, low frequency notch setting
/// @param input Input signal.
- (instancetype)initWithPresetWideHighFrequencyNotchFilterWithInput:(AKParameter *)input;

/// Instantiates the equalizer filter with a wide, low frequency notch setting
/// @param input Input signal.
+ (instancetype)presetWideHighFrequencyNotchFilterWithInput:(AKParameter *)input;

/// Instantiates the equalizer filter with a wide, high frequency notch setting
/// @param input Input signal.
- (instancetype)initWithPresetWideLowFrequencyNotchFilterWithInput:(AKParameter *)input;

/// Instantiates the equalizer filter with a wide, high frequency notch setting
/// @param input Input signal.
+ (instancetype)presetWideLowFrequencyNotchFilterWithInput:(AKParameter *)input;


/// Filter center frequency in Hz. [Default Value: 1000]
@property (nonatomic) AKParameter *centerFrequency;

/// Set an optional center frequency
/// @param centerFrequency Filter center frequency in Hz. Updated at Control-rate. [Default Value: 1000]
- (void)setOptionalCenterFrequency:(AKParameter *)centerFrequency;

/// Peak/notch bandwidth in Hz. [Default Value: 100]
@property (nonatomic) AKParameter *bandwidth;

/// Set an optional bandwidth
/// @param bandwidth Peak/notch bandwidth in Hz. Updated at Control-rate. [Default Value: 100]
- (void)setOptionalBandwidth:(AKParameter *)bandwidth;

/// Peak/notch gain. [Default Value: 10]
@property (nonatomic) AKParameter *gain;

/// Set an optional gain
/// @param gain Peak/notch gain. Updated at Control-rate. [Default Value: 10]
- (void)setOptionalGain:(AKParameter *)gain;



@end
NS_ASSUME_NONNULL_END
