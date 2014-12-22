//
//  AKLowPassFilter.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/22/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A first-order recursive low-pass filter with variable frequency response.

 More detailed description from http://www.csounds.com/manual/html/tone.html
 */

@interface AKLowPassFilter : AKAudio
/// Instantiates the low pass filter with all values
/// @param audioSource The control to be filtered [Default Value: ]
/// @param halfPowerPoint The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2. [Default Value: 1000]
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                     halfPowerPoint:(AKControl *)halfPowerPoint;

/// Instantiates the low pass filter with default values
/// @param audioSource The control to be filtered
- (instancetype)initWithAudioSource:(AKAudio *)audioSource;

/// Instantiates the low pass filter with default values
/// @param audioSource The control to be filtered
+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource;

/// The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2. [Default Value: 1000]
@property AKControl *halfPowerPoint;

/// Set an optional half power point
/// @param halfPowerPoint The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2. [Default Value: 1000]
- (void)setOptionalHalfPowerPoint:(AKControl *)halfPowerPoint;



@end
