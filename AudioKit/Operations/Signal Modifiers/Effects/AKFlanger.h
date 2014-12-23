//
//  AKFlanger.h
//  AudioKit
//
//  Auto-generated on 12/21/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Flange effect

 This is useful for generating choruses and flangers. The delay must be varied at audio-rate connecting delay to an oscillator output.
 */

@interface AKFlanger : AKAudio
/// Instantiates the flanger with all values
/// @param audioSource Input signal. [Default Value: ]
/// @param delayTime Delay in seconds [Default Value: ]
/// @param feedback Feedback amount (in normal tasks this should not exceed 1, even if bigger values are allowed) [Default Value: 0]
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                          delayTime:(AKAudio *)delayTime
                           feedback:(AKControl *)feedback;

/// Instantiates the flanger with default values
/// @param audioSource Input signal.
/// @param delayTime Delay in seconds
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                          delayTime:(AKAudio *)delayTime;

/// Instantiates the flanger with default values
/// @param audioSource Input signal.
/// @param delayTime Delay in seconds
+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource                           delayTime:(AKAudio *)delayTime;

/// Feedback amount (in normal tasks this should not exceed 1, even if bigger values are allowed) [Default Value: 0]
@property AKControl *feedback;

/// Set an optional feedback
/// @param feedback Feedback amount (in normal tasks this should not exceed 1, even if bigger values are allowed) [Default Value: 0]
- (void)setOptionalFeedback:(AKControl *)feedback;



@end
