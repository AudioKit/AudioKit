//
//  OCSMinAudio.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 12/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** Produces a signal that is the minimum of any number of input signals.
 
 Takes any number of audio signals and outputs an audio signal that is the minimum of all of the inputs.
 */

@interface OCSMinAudio : OCSAudio

/// Finds the minimum audio signal from an array of sources
/// @param inputAudioSources Array of audio sources
- (id)initWithAudioSources:(OCSArray *)inputAudioSources;

@end