//
//  AKStereoAudio.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/12/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"

/** Stereo Audio Pair
 */

@interface AKStereoAudio : AKParameter

/// The output to the left channel.
@property (nonatomic) AKParameter *leftOutput;
/// The output to the right channel.
@property (nonatomic) AKParameter *rightOutput;

/// Create an audio pair from left and right inputs
/// @param leftAudio  Left channel input
/// @param rightAudio Rigt channel input
- (instancetype)initWithLeftAudio:(AKParameter *)leftAudio
                       rightAudio:(AKParameter *)rightAudio;

/// Quick and dirty way to get a stereo signal from a mono.
/// @param mono Regular mono audio source.
+ (instancetype)stereoFromMono:(AKParameter *)mono;

/// Create a parameter available to all instruments in the orchestra.
+ (instancetype)globalParameter;

/// Create a parameter available to all instruments in the orchestra.
/// @param name The name of the parameter as it should appear in the output File.
+ (instancetype)globalParameterWithString:(NSString *)name;

/// Scale both sides of an audio pair equally.
/// @param scalingFactor Amount by which to scale the audio.
- (instancetype)scaledBy:(AKParameter *)scalingFactor;

@end
