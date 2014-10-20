//
//  AKVariableDelay.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** An interpolating variable time delay.
 */

@interface AKVariableDelay : AKAudio

/// Instantiates the variable delay
/// @param audioSource Input signal.
/// @param delayTime Current value of delay in milliseconds. Note that linear functions have no pitch change effects. Fast changing values will cause discontinuities in the waveform resulting noise.
/// @param maximumDelayTime Maximum value of delay in milliseconds.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                          delayTime:(AKAudio *)delayTime
                   maximumDelayTime:(AKConstant *)maximumDelayTime;

@end
