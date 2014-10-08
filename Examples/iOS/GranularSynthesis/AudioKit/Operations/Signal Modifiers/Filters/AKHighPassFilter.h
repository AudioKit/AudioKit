//
//  AKHighPassFilter.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A first-order recursive high-pass filter with variable frequency response.
 
 A complement to the AKLowPassFilter.
 */

@interface AKHighPassFilter : AKAudio

/// Instantiates the high pass filter
/// @param audioSource    The audio to be filtered
/// @param halfPowerPoint The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                     halfPowerPoint:(AKControl *)halfPowerPoint;

@end