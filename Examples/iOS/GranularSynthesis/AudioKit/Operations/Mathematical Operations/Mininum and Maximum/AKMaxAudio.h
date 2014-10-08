//
//  AKMaxAudio.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Produces a signal that is the maximum of any number of input signals.
 
 Takes any number of audio signals and outputs an audio signal that is the maximum of all of the inputs.
 */

@interface AKMaxAudio : AKAudio

/// Finds the maximum audio signal from an array of sources
/// @param inputAudioSources Array of audio sources
- (instancetype)initWithAudioSources:(AKArray *)inputAudioSources;

@end