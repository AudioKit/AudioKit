//
//  AKVariableFrequencyResponseBandPassFilter.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/27/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A second-order resonant filter.
 
 This is a second-order filter defined by a center frequency which is the frequency position of the peak response, and a bandwidth which is the frequency difference between the upper and lower half-power points.
 */

@interface AKVariableFrequencyResponseBandPassFilter : AKAudio

/// Instantiates the variable frequency response band pass filter
/// @param audioSource     The input signal to be filtered.
/// @param cutoffFrequency Cutoff or resonant frequency of the filter, measured in Hz.
/// @param bandwidth       Bandwidth of the filter (the Hz difference between the upper and lower half-power points).
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                    cutoffFrequency:(AKControl *)cutoffFrequency
                          bandwidth:(AKControl *)bandwidth;

@end