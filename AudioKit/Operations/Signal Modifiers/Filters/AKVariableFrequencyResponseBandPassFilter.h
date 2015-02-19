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

@interface AKVariableFrequencyResponseBandPassFilter : AKAudio

// Type Helpers

/// No scaling of the output
+ (AKConstant *)scalingFactorNone;

/// Signifies a peak response factor of 1, i.e. all frequencies other than the cutoffFrequency are attenuated in accordance with the (normalized) response curve.
+ (AKConstant *)scalingFactorPeak;

/// Raises the response factor so that its overall RMS value equals 1. This intended equalization of input and output power assumes all frequencies are physically present; hence it is most applicable to white noise.
+ (AKConstant *)scalingFactorRMS;

/// Instantiates the variable frequency response band pass filter with all values
/// @param audioSource The input signal to be filtered. [Default Value: ]
/// @param cutoffFrequency Cutoff or resonant frequency of the filter, measured in Hz. Updated at Control-rate. [Default Value: 1000]
/// @param bandwidth Bandwidth of the filter (the Hz difference between the upper and lower half-power points). Updated at Control-rate. [Default Value: 10]
/// @param scalingFactor There are three scaling factors possible, 'None' (Default, 0), 'Peak' or 1, and 'RMS' or 2.  All are accessibly through class function 'scalingFactor...'   'Peak' signifies a peak response factor of 1, i.e. all frequencies other than the cutoffFrequency are attenuated in accordance with the (normalized) response curve. 'RMS' raises the response factor so that its overall RMS value equals 1. This intended equalization of input and output power assumes all frequencies are physically present; hence it is most applicable to white noise.   [Default Value: 0]
- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                    cutoffFrequency:(AKParameter *)cutoffFrequency
                          bandwidth:(AKParameter *)bandwidth
                      scalingFactor:(AKConstant *)scalingFactor;

/// Instantiates the variable frequency response band pass filter with default values
/// @param audioSource The input signal to be filtered.
- (instancetype)initWithAudioSource:(AKParameter *)audioSource;

/// Instantiates the variable frequency response band pass filter with default values
/// @param audioSource The input signal to be filtered.
+ (instancetype)filterWithAudioSource:(AKParameter *)audioSource;

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

/// There are three scaling factors possible, 'None' (Default, 0), 'Peak' or 1, and 'RMS' or 2.  All are accessibly through class function 'scalingFactor...'   'Peak' signifies a peak response factor of 1, i.e. all frequencies other than the cutoffFrequency are attenuated in accordance with the (normalized) response curve. 'RMS' raises the response factor so that its overall RMS value equals 1. This intended equalization of input and output power assumes all frequencies are physically present; hence it is most applicable to white noise.   [Default Value: 0]
@property (nonatomic) AKConstant *scalingFactor;

/// Set an optional scaling factor
/// @param scalingFactor There are three scaling factors possible, 'None' (Default, 0), 'Peak' or 1, and 'RMS' or 2.  All are accessibly through class function 'scalingFactor...'   'Peak' signifies a peak response factor of 1, i.e. all frequencies other than the cutoffFrequency are attenuated in accordance with the (normalized) response curve. 'RMS' raises the response factor so that its overall RMS value equals 1. This intended equalization of input and output power assumes all frequencies are physically present; hence it is most applicable to white noise.   [Default Value: 0]
- (void)setOptionalScalingFactor:(AKConstant *)scalingFactor;


@end
