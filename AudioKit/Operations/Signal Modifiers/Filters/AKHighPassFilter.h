//
//  AKHighPassFilter.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/19/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A first-order recursive high-pass filter with variable frequency response.

 A complement to the AKLowPassFilter.
 */

@interface AKHighPassFilter : AKAudio
/// Instantiates the high pass filter with all values
/// @param audioSource The audio to be filtered [Default Value: ]
/// @param cutoffFrequency The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2. [Default Value: 4000]
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                    cutoffFrequency:(AKControl *)cutoffFrequency;

/// Instantiates the high pass filter with default values
/// @param audioSource The audio to be filtered
- (instancetype)initWithAudioSource:(AKAudio *)audioSource;

/// Instantiates the high pass filter with default values
/// @param audioSource The audio to be filtered
+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource;
/// The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2. [Default Value: 4000]
@property AKControl *cutoffFrequency;

/// Set an optional cutoff frequency
/// @param cutoffFrequency The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2. [Default Value: 4000]
- (void)setOptionalCutoffFrequency:(AKControl *)cutoffFrequency;



@end
