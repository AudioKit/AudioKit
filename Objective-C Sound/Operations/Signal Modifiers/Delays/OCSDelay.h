//
//  OCSDelay.h
//  Objective-C Sound
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** Simple audio delay
 
 Delays an input signal by some time interval.
 */

@interface OCSDelay : OCSAudio

/// Instantiates the delay
/// @param audioSource Audio signal
/// @param delayTime Requested delay time in seconds.
- (instancetype)initWithAudioSource:(OCSAudio *)audioSource
                          delayTime:(OCSConstant *)delayTime;

@end