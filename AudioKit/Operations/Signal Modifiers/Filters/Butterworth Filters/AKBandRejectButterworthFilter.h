//
//  AKBandRejectButterworthFilter.h
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A band-reject Butterworth filter.

 These filters are Butterworth second-order IIR filters. They offer an almost flat passband and very good precision and stopband attenuation.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKBandRejectButterworthFilter : AKAudio
/// Instantiates the band reject butterworth filter with all values
/// @param input Input signal to be filtered. 
/// @param centerFrequency Center frequency for each of the filters. Updated at Control-rate. [Default Value: 3000]
/// @param bandwidth Bandwidth of the band-reject filters. Updated at Control-rate. [Default Value: 2000]
- (instancetype)initWithInput:(AKParameter *)input
              centerFrequency:(AKParameter *)centerFrequency
                    bandwidth:(AKParameter *)bandwidth;

/// Instantiates the band reject butterworth filter with default values
/// @param input Input signal to be filtered.
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the band reject butterworth filter with default values
/// @param input Input signal to be filtered.
+ (instancetype)filterWithInput:(AKParameter *)input;

/// Instantiates the band reject butterworth filter with default values
/// @param input Input signal to be filtered.
- (instancetype)initWithPresetDefaultFilterWithInput:(AKParameter *)input;

/// Instantiates the band reject butterworth filter with default values
/// @param input Input signal to be filtered.
+ (instancetype)presetDefaultFilterWithInput:(AKParameter *)input;

/// Instantiates the band reject butterworth filter with a treble-heavy sound
/// @param input Input signal to be filtered.
- (instancetype)initWithPresetBassRejectFilterWithInput:(AKParameter *)input;

/// Instantiates the band reject butterworth filter with a treble-heavy sound
/// @param input Input signal to be filtered.
+ (instancetype)presetBassRejectFilterWithInput:(AKParameter *)input;

/// Instantiates the band reject butterworth filter with a bass-heavy sound
/// @param input Input signal to be filtered.
- (instancetype)initWithPresetTrebleRejectFilterWithInput:(AKParameter *)input;

/// Instantiates the band reject butterworth filter with a bass-heavy sound
/// @param input Input signal to be filtered.
+ (instancetype)presetTrebleRejectFilterWithInput:(AKParameter *)input;

/// Center frequency for each of the filters. [Default Value: 3000]
@property (nonatomic) AKParameter *centerFrequency;

/// Set an optional center frequency
/// @param centerFrequency Center frequency for each of the filters. Updated at Control-rate. [Default Value: 3000]
- (void)setOptionalCenterFrequency:(AKParameter *)centerFrequency;

/// Bandwidth of the band-reject filters. [Default Value: 2000]
@property (nonatomic) AKParameter *bandwidth;

/// Set an optional bandwidth
/// @param bandwidth Bandwidth of the band-reject filters. Updated at Control-rate. [Default Value: 2000]
- (void)setOptionalBandwidth:(AKParameter *)bandwidth;



@end
NS_ASSUME_NONNULL_END
