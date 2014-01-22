//
//  AKResonantFilter.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A second-order resonant filter.
 
 This is a second-order filter defined by a center frequency which is the frequency position of the peak response, and a bandwidth which is the frequency difference between the upper and lower half-power points.
 */

@interface AKResonantFilter : AKAudio

/// Instantiates the resonant filter
/// @param audioSource The input audio stream.
/// @param centerFrequency Center frequency of the filter, or frequency position of the peak response.
/// @param bandwidth Bandwidth of the filter (the Hz difference between the upper and lower half-power points).
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                    centerFrequency:(AKControl *)centerFrequency
                          bandwidth:(AKControl *)bandwidth;

@end