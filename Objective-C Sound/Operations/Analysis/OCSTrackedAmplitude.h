//
//  OCSTrackedAmplitude.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 11/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParameter+Operation.h"
#import "OCSAudio.h"

/** Determines the root-mean-square amplitude of an audio signal.
 
 Determines the root-mean-square amplitude of an audio signal. 
 It low-pass filters the actual value, to average in the manner of a VU meter.
 
 */

@interface OCSTrackedAmplitude : OCSControl

/// Initialize the tracked amplitude.
/// @param audioSource Input signal.
- (instancetype)initWithAudioSource:(OCSAudio *)audioSource;

@end
