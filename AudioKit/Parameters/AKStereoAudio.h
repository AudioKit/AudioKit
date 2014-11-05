//
//  AKStereoAudio.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"

/** Stereo Audio Pair
 */

@interface AKStereoAudio : AKParameter

/// The output to the left channel.
@property (nonatomic, strong) AKAudio *leftOutput;
/// The output to the right channel.
@property (nonatomic, strong) AKAudio *rightOutput;

/// Create an audio pair from left and right inputs
/// @param leftAudio  Left channel input
/// @param rightAudio Rigt channel input
- (instancetype)initWithLeftAudio:(AKAudio *)leftAudio
                       rightAudio:(AKAudio *)rightAudio;

/// Allows the unique identifying integer to be reset so that the numbers don't increment indefinitely.
+ (void)resetID;

/// Quick and dirty way to get a stereo signal from a mono.
/// @param mono Regular mono audio source.
+ (AKStereoAudio *)stereoFromMono:(AKAudio *)mono;

/// Scale both sides of an audio pair equally.
/// @param scalingFactor Amount by which to scale the audio.
- (instancetype)scaledBy:(AKParameter *)scalingFactor;

@end
