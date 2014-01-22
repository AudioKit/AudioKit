//
//  AKDelay.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Simple audio delay
 
 Delays an input signal by some time interval.
 */

@interface AKDelay : AKAudio

/// Instantiates the delay
/// @param audioSource Audio signal
/// @param delayTime Requested delay time in seconds.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                          delayTime:(AKConstant *)delayTime;

- (void)setOptionalFeedback:(AKControl *)feedback;
@end