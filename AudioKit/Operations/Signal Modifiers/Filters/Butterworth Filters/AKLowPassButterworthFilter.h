//
//  AKLowPassButterworthFilter.h
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A low-pass Butterworth filter.

 These filters are Butterworth second-order IIR filters. They offer an almost flat passband and very good precision and stopband attenuation.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKLowPassButterworthFilter : AKAudio
/// Instantiates the low pass butterworth filter with all values
/// @param input signal to be filtered. 
/// @param cutoffFrequency Cutoff frequency for each of the filters. Updated at Control-rate. [Default Value: 1000]
- (instancetype)initWithInput:(AKParameter *)input
              cutoffFrequency:(AKParameter *)cutoffFrequency;

/// Instantiates the low pass butterworth filter with default values
/// @param input Input signal to be filtered.
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the low pass butterworth filter with default values
/// @param input Input signal to be filtered.
+ (instancetype)filterWithInput:(AKParameter *)input;

/// Instantiates the low pass butterworth filter with default values
/// @param input Input signal to be filtered.
- (instancetype)initWithPresetDefaultFilterWithInput:(AKParameter *)input;

/// Instantiates the low pass butterworth filter with default values
/// @param input Input signal to be filtered.
+ (instancetype)presetDefaultFilterWithInput:(AKParameter *)input;

/// Instantiates the low pass butterworth filter with an extremely bass heavy sound
/// @param input Input signal to be filtered.
- (instancetype)initWithPresetBassHeavyFilterWithInput:(AKParameter *)input;

/// Instantiates the low pass butterworth filter with an extremely bass heavy sound
/// @param input Input signal to be filtered.
+ (instancetype)presetBassHeavyFilterWithInput:(AKParameter *)input;

/// Instantiates the low pass butterworth filter with an mildly bassy sound
/// @param input Input signal to be filtered.
- (instancetype)initWithPresetMildBassFilterWithInput:(AKParameter *)input;

/// Instantiates the low pass butterworth filter with an mildly bassy sound
/// @param input Input signal to be filtered.
+ (instancetype)presetMildBassFilterWithInput:(AKParameter *)input;

/// Cutoff frequency for each of the filters. [Default Value: 1000]
@property (nonatomic) AKParameter *cutoffFrequency;

/// Set an optional cutoff frequency
/// @param cutoffFrequency Cutoff frequency for each of the filters. Updated at Control-rate. [Default Value: 1000]
- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency;



@end
NS_ASSUME_NONNULL_END
