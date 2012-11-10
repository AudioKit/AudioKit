//
//  OCSAudioOutput.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSStereoAudio.h"
#import "OCSParameter+Operation.h"

/** Writes stereo audio data to an external device or stream.
 
 Sends stereo audio samples to an accumulating output buffer 
 (created at the beginning of performance) which serves to 
 collect the output of all active instruments before the 
 sound is written to disk. There can be any number of these 
 output units in an instrument.
 
 */
@interface OCSAudioOutput : OCSParameter

/// Helper function to send both channels the same monoSignal
/// @param monoSignal The audio signal to be played on both channels.
- (id)initWithSourceAudio:(OCSAudio *)sourceAudio;

/// Send a stereo output pair
/// @param stereoSignal The audio as an OCSStereoAudio pair
- (id)initWithStereoInput:(OCSStereoAudio *)stereoAudio;

/// Initialization Statement
/// @param leftAudio  The audio signal to be played on the left channel.
/// @param rightAudio The audio signal to be played on the right channel.
- (id)initWithLeftAudio:(OCSAudio *)leftAudio rightAudio:(OCSAudio *)rightAudio;

@end
