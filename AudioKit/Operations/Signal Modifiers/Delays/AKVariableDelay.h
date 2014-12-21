//
//  AKVariableDelay.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** An interpolating variable time delay.

 
 */

@interface AKVariableDelay : AKAudio
/// Instantiates the variable delay with all values
/// @param audioSource Input signal. [Default Value: ]
/// @param delayTime Current value of delay in milliseconds. Note that linear functions have no pitch change effects. Fast changing values will cause discontinuities in the waveform resulting noise. [Default Value: ]
/// @param maximumDelayTime Maximum value of delay in milliseconds. [Default Value: 2000]
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                          delayTime:(AKAudio *)delayTime
                   maximumDelayTime:(AKConstant *)maximumDelayTime;

/// Instantiates the variable delay with default values
/// @param audioSource Input signal.
/// @param delayTime Current value of delay in milliseconds. Note that linear functions have no pitch change effects. Fast changing values will cause discontinuities in the waveform resulting noise.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                          delayTime:(AKAudio *)delayTime;

/// Instantiates the variable delay with default values
/// @param audioSource Input signal.
/// @param delayTime Current value of delay in milliseconds. Note that linear functions have no pitch change effects. Fast changing values will cause discontinuities in the waveform resulting noise.
+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource                           delayTime:(AKAudio *)delayTime;
/// Maximum value of delay in milliseconds. [Default Value: 2000]
@property AKConstant *maximumDelayTime;

/// Set an optional maximum delay time
/// @param maximumDelayTime Maximum value of delay in milliseconds. [Default Value: 2000]
- (void)setOptionalMaximumDelayTime:(AKConstant *)maximumDelayTime;



@end
