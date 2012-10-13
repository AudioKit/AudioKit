//
//  OCSAudioOutput.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** Writes stereo audio data to an external device or stream.
 
 Sends stereo audio samples to an accumulating output buffer 
 (created at the beginning of performance) which serves to 
 collect the output of all active instruments before the 
 sound is written to disk. There can be any number of these 
 output units in an instrument.
 
 */
@interface OCSAudioOutput : OCSParameter

/// @name Initialization

/// Helper function to send both channels the same monoSignal
/// @param monoSignal The audio signal to be played on both channels.
- (id)initWithMonoInput:(OCSAudio *)monoSignal;

/// Initialization Statement
/// @param leftInput  The audio signal to be played on the left channel.
/// @param rightInput The audio signal to be played on the right channel.
- (id)initWithLeftInput:(OCSAudio *)leftInput rightInput:(OCSAudio *)rightInput;

@end
