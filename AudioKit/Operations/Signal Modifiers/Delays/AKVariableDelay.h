//
//  AKVariableDelay.h
//  AudioKit
//
//  Auto-generated on 12/27/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** An interpolating variable time delay.

 
 */

@interface AKVariableDelay : AKAudio
/// Instantiates the variable delay with all values
/// @param input Input signal. [Default Value: ]
/// @param delayTime Current value of delay in milliseconds. Note that linear functions have no pitch change effects. Fast changing values will cause discontinuities in the waveform resulting noise. [Default Value: ]
/// @param maximumDelayTime Maximum value of delay in milliseconds. [Default Value: 50]
- (instancetype)initWithInput:(AKParameter *)input
                    delayTime:(AKParameter *)delayTime
             maximumDelayTime:(AKConstant *)maximumDelayTime;

/// Instantiates the variable delay with default values
/// @param input Input signal.
/// @param delayTime Current value of delay in milliseconds. Note that linear functions have no pitch change effects. Fast changing values will cause discontinuities in the waveform resulting noise.
- (instancetype)initWithInput:(AKParameter *)input
                    delayTime:(AKParameter *)delayTime;

/// Instantiates the variable delay with default values
/// @param input Input signal.
/// @param delayTime Current value of delay in milliseconds. Note that linear functions have no pitch change effects. Fast changing values will cause discontinuities in the waveform resulting noise.
+ (instancetype)audioWithInput:(AKParameter *)input
                     delayTime:(AKParameter *)delayTime;

/// Maximum value of delay in milliseconds. [Default Value: 50]
@property AKConstant *maximumDelayTime;

/// Set an optional maximum delay time
/// @param maximumDelayTime Maximum value of delay in milliseconds. [Default Value: 50]
- (void)setOptionalMaximumDelayTime:(AKConstant *)maximumDelayTime;



@end
