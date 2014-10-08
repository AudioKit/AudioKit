//
//  AKBeatenPlate.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/25/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A model of beaten plate consisting of two parallel delay-lines and two first-order lowpass filters.
 
 This  is a model of beaten plate consisting of two parallel delay-lines and two first-order lowpass filters. The two feedback lines are mixed and sent to the delay again each cycle.
 */

@interface AKBeatenPlate : AKAudio

/// Instantiates the beaten plate
/// @param audioSource The excitation noise.
/// @param frequency1 The inverse of delay time for the first of two parallel delay lines.
/// @param frequency2 The inverse of delay time for the second of two parallel delay lines.
/// @param cutoffFrequency1 The filter cutoff frequency in Hz for the first low-pass filter.
/// @param cutoffFrequency2 The filter cutoff frequency in Hz for the second low-pass filter.
/// @param feedback1 The feedback factor for the first effects loop.
/// @param feedback2 The feedback factor for the second effects loop.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                         frequency1:(AKParameter *)frequency1
                         frequency2:(AKParameter *)frequency2
                   cutoffFrequency1:(AKControl *)cutoffFrequency1
                   cutoffFrequency2:(AKControl *)cutoffFrequency2
                          feedback1:(AKControl *)feedback1
                          feedback2:(AKControl *)feedback2;

@end