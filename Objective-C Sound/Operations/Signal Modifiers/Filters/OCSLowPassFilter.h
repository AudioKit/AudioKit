//
//  OCSLowPassFilter.h
//  Objective-C Sound
//
//  Auto-generated from database on 11/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** A first-order recursive low-pass filter with variable frequency response.
 
 More detailed description from http://www.csounds.com/manual/html/tone.html
 */

@interface OCSLowPassFilter : OCSAudio

/// Instantiates the low pass filter
/// @param audioSource The audio to be filtered
/// @param halfPowerPoint The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2.
- (instancetype)initWithAudioSource:(OCSAudio *)audioSource
                     halfPowerPoint:(OCSControl *)halfPowerPoint;

@end