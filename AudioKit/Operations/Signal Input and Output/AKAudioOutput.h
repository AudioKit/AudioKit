//
//  AKAudioOutput.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKStereoAudio.h"
#import "AKParameter+Operation.h"

/** Writes stereo audio data to an external device or stream.
 
 Sends stereo audio samples to an accumulating output buffer 
 (created at the beginning of performance) which serves to 
 collect the output of all active instruments before the 
 sound is written to disk. There can be any number of these 
 output units in an instrument.
 
 */
@interface AKAudioOutput : AKParameter

/// Helper function to send both channels the same monoSignal
/// @param audioSource The audio signal to be played on both channels.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource;

/// Send a stereo output pair
/// @param stereoAudio The audio as an AKStereoAudio pair
- (instancetype)initWithStereoAudioSource:(AKStereoAudio *)stereoAudio;

/// Initialization Statement
/// @param leftAudio  The audio signal to be played on the left channel.
/// @param rightAudio The audio signal to be played on the right channel.
- (instancetype)initWithLeftAudio:(AKAudio *)leftAudio
                       rightAudio:(AKAudio *)rightAudio;

@end
