//
//  AKSimpleWaveGuideModel.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/25/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A simple waveguide model consisting of one delay-line and one first-order lowpass filter.
 
 This is the most elemental waveguide model, consisting of one delay-line and one first-order lowpass filter.
 */

@interface AKSimpleWaveGuideModel : AKAudio

/// Instantiates the simple wave guide model
/// @param audioSource The excitation noise.
/// @param frequency The inverse of delay time.
/// @param cutoff Filter cut-off frequency in Hz
/// @param feedback Feedback factor usually between 0 and 1
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                          frequency:(AKParameter *)frequency
                             cutoff:(AKControl *)cutoff
                           feedback:(AKControl *)feedback;

@end