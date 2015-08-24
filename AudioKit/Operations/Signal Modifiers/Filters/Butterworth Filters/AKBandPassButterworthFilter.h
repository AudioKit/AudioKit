//
//  AKBandPassButterworthFilter.h
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A band-pass Butterworth filter.

 These filters are Butterworth second-order IIR filters. They offer an almost flat passband and very good precision and stopband attenuation.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKBandPassButterworthFilter : AKAudio
/// Instantiates the band pass butterworth filter with all values
/// @param input Input signal to be filtered. 
/// @param centerFrequency Center frequency for each of the filters. Updated at Control-rate. [Default Value: 2000]
/// @param bandwidth Bandwidth of the band-pass filters. Updated at Control-rate. [Default Value: 100]
- (instancetype)initWithInput:(AKParameter *)input
              centerFrequency:(AKParameter *)centerFrequency
                    bandwidth:(AKParameter *)bandwidth;

/// Instantiates the band pass butterworth filter with default values
/// @param input Input signal to be filtered.
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the band pass butterworth filter with default values
/// @param input Input signal to be filtered.
+ (instancetype)filterWithInput:(AKParameter *)input;

/// Instantiates the band pass butterworth filter with default values
/// @param input Input signal to be filtered.
- (instancetype)initWithPresetDefaultFilterWithInput:(AKParameter *)input;

/// Instantiates the band pass butterworth filter with default values
/// @param input Input signal to be filtered.
+ (instancetype)presetDefaultFilterWithInput:(AKParameter *)input;

/// Instantiates the band pass butterworth filter with a bass heavy sound
/// @param input Input signal to be filtered.
- (instancetype)initWithPresetBassHeavyFilterWithInput:(AKParameter *)input;

/// Instantiates the band pass butterworth filter with a bass heavy sound
/// @param input Input signal to be filtered.
+ (instancetype)presetBassHeavyFilterWithInput:(AKParameter *)input;

/// Instantiates the band pass butterworth filter with a treble heavy sound
/// @param input Input signal to be filtered.
- (instancetype)initWithPresetTrebleHeavyFilterWithInput:(AKParameter *)input;

/// Instantiates the band pass butterworth filter with a treble heavy sound
/// @param input Input signal to be filtered.
+ (instancetype)presetTrebleHeavyFilterWithInput:(AKParameter *)input;


/// Center frequency for each of the filters. [Default Value: 2000]
@property (nonatomic) AKParameter *centerFrequency;

/// Set an optional center frequency
/// @param centerFrequency Center frequency for each of the filters. Updated at Control-rate. [Default Value: 2000]
- (void)setOptionalCenterFrequency:(AKParameter *)centerFrequency;

/// Bandwidth of the band-pass filters. [Default Value: 100]
@property (nonatomic) AKParameter *bandwidth;

/// Set an optional bandwidth
/// @param bandwidth Bandwidth of the band-pass filters. Updated at Control-rate. [Default Value: 100]
- (void)setOptionalBandwidth:(AKParameter *)bandwidth;



@end
NS_ASSUME_NONNULL_END
