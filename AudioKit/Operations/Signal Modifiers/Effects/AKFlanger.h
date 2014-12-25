//
//  AKFlanger.h
//  AudioKit
//
//  Auto-generated on 12/25/14.
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
/// @param feedback Feedback amount (in normal tasks this should not exceed 1, even if bigger values are allowed) Updated at Control-rate. [Default Value: 0]
- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                          delayTime:(AKParameter *)delayTime
                           feedback:(AKParameter *)feedback;

/// Instantiates the flanger with default values
/// @param audioSource Input signal.
/// @param delayTime Delay in seconds
- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                          delayTime:(AKParameter *)delayTime;

/// Instantiates the flanger with default values
/// @param audioSource Input signal.
/// @param delayTime Delay in seconds
+ (instancetype)audioWithAudioSource:(AKParameter *)audioSource
                           delayTime:(AKParameter *)delayTime;

/// Feedback amount (in normal tasks this should not exceed 1, even if bigger values are allowed) [Default Value: 0]
@property AKParameter *feedback;

/// Set an optional feedback
/// @param feedback Feedback amount (in normal tasks this should not exceed 1, even if bigger values are allowed) Updated at Control-rate. [Default Value: 0]
- (void)setOptionalFeedback:(AKParameter *)feedback;



@end
