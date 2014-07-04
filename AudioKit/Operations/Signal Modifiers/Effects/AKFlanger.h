//
//  AKFlanger.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Flange effect
 
 This is useful for generating choruses and flangers. The delay must be varied at
 audio-rate.
 */

@interface AKFlanger : AKAudio

/// Instantiates the flanger
/// @param sourceSignal Input signal.
/// @param delayTime Delay in seconds
/// @param feedback Feedback amount (in normal tasks this should not exceed 1, even if bigger values are allowed)

- (instancetype)initWithSourceSignal:(AKAudio *)sourceSignal
                           delayTime:(AKAudio *)delayTime
                            feedback:(AKControl *)feedback;

@end