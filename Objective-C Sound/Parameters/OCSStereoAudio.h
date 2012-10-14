//
//  OCSStereoAudio.h
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 10/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"

/** Stereo Audio Pair 
 */

@interface OCSStereoAudio : OCSParameter

/// The output to the left channel.
@property (nonatomic, strong) OCSAudio *leftOutput;
/// The output to the right channel.
@property (nonatomic, strong) OCSAudio *rightOutput;

/// Create an audio pair from left and right inputs
/// @param leftInput  Left channel input
/// @param rightInput Rigt channel input
- (id)initWithLeftInput:(OCSAudio *)leftInput
             rightInput:(OCSAudio *)rightInput;

/// Allows the unique identifying integer to be reset so that the numbers don't increment indefinitely.
+ (void)resetID;

/// Quick and dirty way to get a stereo signal from a mono.
/// @param mono Regular mono audio source.
+ (OCSStereoAudio *)stereoFromMono:(OCSAudio *)mono;

/// Scale both sides of an audio pair equally.
/// @param scalingFactor Amount by which to scale the audio.
- (id)scaledBy:(float)scalingFactor;

@end
