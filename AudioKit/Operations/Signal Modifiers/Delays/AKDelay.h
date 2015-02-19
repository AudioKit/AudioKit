//
//  AKDelay.h
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Simple audio delay

 Delays an input signal by some time interval.
 */

@interface AKDelay : AKAudio
/// Instantiates the delay with all values
/// @param input Input signal, usually audio.
/// @param delayTime Requested delay time in seconds.
/// @param feedback How much of the signal is sent back into the delay line.  Usually values range from 0-1. Updated at Control-rate. [Default Value: 0.0]
- (instancetype)initWithInput:(AKParameter *)input
                    delayTime:(AKConstant *)delayTime
                     feedback:(AKParameter *)feedback;

/// Instantiates the delay with default values
/// @param input Input signal, usually audio.
/// @param delayTime Requested delay time in seconds.
- (instancetype)initWithInput:(AKParameter *)input
                    delayTime:(AKConstant *)delayTime;

/// Instantiates the delay with default values
/// @param input Input signal, usually audio.
/// @param delayTime Requested delay time in seconds.
+ (instancetype)delayWithInput:(AKParameter *)input
                     delayTime:(AKConstant *)delayTime;

/// How much of the signal is sent back into the delay line.  Usually values range from 0-1. [Default Value: 0.0]
@property (nonatomic) AKParameter *feedback;

/// Set an optional feedback
/// @param feedback How much of the signal is sent back into the delay line.  Usually values range from 0-1. Updated at Control-rate. [Default Value: 0.0]
- (void)setOptionalFeedback:(AKParameter *)feedback;



@end
