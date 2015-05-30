//
//  AKVariableFrequencyResponseBandPassFilter.h
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Customized by Aurelius Prochazka to add type helpers
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A second-order resonant filter.
 
 This is a second-order filter defined by a center frequency which is the frequency position of the peak response, and a bandwidth which is the frequency difference between the upper and lower half-power points.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKVariableFrequencyResponseBandPassFilter : AKAudio

// Type Helpers

/// No scaling of the output
+ (AKConstant *)scalingFactorNone;

/// Signifies a peak response factor of 1, i.e. all frequencies other than the cutoffFrequency are attenuated in accordance with the (normalized) response curve.
+ (AKConstant *)scalingFactorPeak;

/// Raises the response factor so that its overall RMS value equals 1. This intended equalization of input and output power assumes all frequencies are physically present; hence it is most applicable to white noise.
+ (AKConstant *)scalingFactorRMS;

/// Instantiates the variable frequency response band pass filter with all values
/// @param input The input signal to be filtered. 
/// @param cutoffFrequency Cutoff or resonant frequency of the filter, measured in Hz. Updated at Control-rate. [Default Value: 1000]
/// @param bandwidth Bandwidth of the filter (the Hz difference between the upper and lower half-power points). Updated at Control-rate. [Default Value: 10]
/// @param scalingFactor There are three scaling factors possible, 'None' (Default, 0), 'Peak' or 1, and 'RMS' or 2.  All are accessibly through class function 'scalingFactor...'   'Peak' signifies a peak response factor of 1, i.e. all frequencies other than the cutoffFrequency are attenuated in accordance with the (normalized) response curve. 'RMS' raises the response factor so that its overall RMS value equals 1. This intended equalization of input and output power assumes all frequencies are physically present; hence it is most applicable to white noise.   [Default Value: 1]
- (instancetype)initWithInput:(AKParameter *)input
              cutoffFrequency:(AKParameter *)cutoffFrequency
                    bandwidth:(AKParameter *)bandwidth
                scalingFactor:(AKConstant *)scalingFactor;

/// Instantiates the variable frequency response band pass filter with default values
/// @param input The input signal to be filtered.
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the variable frequency response band pass filter with default values
/// @param input The input signal to be filtered.
+ (instancetype)filterWithInput:(AKParameter *)input;

/// Instantiates the variable frequency response band pass filter with default values
/// @param input The input signal to be filtered.
- (instancetype)initWithPresetDefaultFilterWithInput:(AKParameter *)input;

/// Instantiates the variable frequency response band pass filter with default values
/// @param input The input signal to be filtered.
+ (instancetype)presetDefautFilterWithInput:(AKParameter *)input;

/// Instantiates the variable frequency response band pass filter with a muffled sound
/// @param input The input signal to be filtered.
- (instancetype)initWithPresetMuffledFilterWithInput:(AKParameter *)input;

/// Instantiates the variable frequency response band pass filter with a muffled sound
/// @param input The input signal to be filtered.
+ (instancetype)presetMuffledFilterWithInput:(AKParameter *)input;

/// Instantiates the variable frequency response band pass filter with a large and muffled sound
/// @param input The input signal to be filtered.
- (instancetype)initWithPresetLargeMuffledFilterWithInput:(AKParameter *)input;

/// Instantiates the variable frequency response band pass filter with a large and muffled sound
/// @param input The input signal to be filtered.
+ (instancetype)presetLargeMuffledFilterWithInput:(AKParameter *)input;

/// Instantiates the variable frequency response band pass filter with a high treble value
/// @param input The input signal to be filtered.
- (instancetype)initWithPresetTreblePeakFilterWithInput:(AKParameter *)input;

/// Instantiates the variable frequency response band pass filter with a high treble value
/// @param input The input signal to be filtered.
+ (instancetype)presetTreblePeakFilterWithInput:(AKParameter *)input;

/// Instantiates the variable frequency response band pass filter with a high bass value
/// @param input The input signal to be filtered.
- (instancetype)initWithPresetBassPeakFilterWithInput:(AKParameter *)input;

/// Instantiates the variable frequency response band pass filter with a high bass value
/// @param input The input signal to be filtered.
+ (instancetype)presetBassPeakFilterWithInput:(AKParameter *)input;


/// Cutoff or resonant frequency of the filter, measured in Hz. [Default Value: 1000]
@property (nonatomic) AKParameter *cutoffFrequency;

/// Set an optional cutoff frequency
/// @param cutoffFrequency Cutoff or resonant frequency of the filter, measured in Hz. Updated at Control-rate. [Default Value: 1000]
- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency;

/// Bandwidth of the filter (the Hz difference between the upper and lower half-power points). [Default Value: 10]
@property (nonatomic) AKParameter *bandwidth;

/// Set an optional bandwidth
/// @param bandwidth Bandwidth of the filter (the Hz difference between the upper and lower half-power points). Updated at Control-rate. [Default Value: 10]
- (void)setOptionalBandwidth:(AKParameter *)bandwidth;

/// There are three scaling factors possible, 'None' or 0, 'Peak' (Default) or 1, and 'RMS' or 2.  All are accessibly through class function 'scalingFactor...'   'Peak' signifies a peak response factor of 1, i.e. all frequencies other than the cutoffFrequency are attenuated in accordance with the (normalized) response curve. 'RMS' raises the response factor so that its overall RMS value equals 1. This intended equalization of input and output power assumes all frequencies are physically present; hence it is most applicable to white noise.   [Default Value: 1]
@property (nonatomic) AKConstant *scalingFactor;

/// Set an optional scaling factor
/// @param scalingFactor /// There are three scaling factors possible, 'None' or 0, 'Peak' (Default) or 1, and 'RMS' or 2.  All are accessibly through class function 'scalingFactor...'   'Peak' signifies a peak response factor of 1, i.e. all frequencies other than the cutoffFrequency are attenuated in accordance with the (normalized) response curve. 'RMS' raises the response factor so that its overall RMS value equals 1. This intended equalization of input and output power assumes all frequencies are physically present; hence it is most applicable to white noise.   [Default Value: 1]
- (void)setOptionalScalingFactor:(AKConstant *)scalingFactor;


@end
NS_ASSUME_NONNULL_END
