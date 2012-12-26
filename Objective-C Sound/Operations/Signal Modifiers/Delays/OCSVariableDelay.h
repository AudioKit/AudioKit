//
//  OCSVariableDelay.h
//  Objective-C Sound
//
//  Auto-generated from database on 12/26/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** An interpolating variable time delay. */

@interface OCSVariableDelay : OCSAudio

/// Instantiates the variable delay
/// @param audioSource Input signal.
/// @param delayTime Current value of delay in milliseconds. Note that linear functions have no pitch change effects. Fast changing values will cause discontinuities in the waveform resulting noise.
/// @param maximumDelayTime Maximum value of delay in milliseconds.
- (id)initWithAudioSource:(OCSAudio *)audioSource
                delayTime:(OCSAudio *)delayTime
         maximumDelayTime:(OCSConstant *)maximumDelayTime;

@end