//
//  OCSPluckDrum.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/25/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParameter+Operation.h"

/** Produces a naturally decaying drum sound based on the Karplus-Strong algorithms.
 The range from pitch to noise is controlled by a Roughness Factor  (0 to 1). 
 Zero gives the plucked string effect, while 1 reverses the polarity of every sample 
 (octave down, odd harmonics). The setting .5 gives an optimum snare drum. 
 The Stretch Factor must be >= 1.  Works best with a flat source (wide pulse), 
 which produces a deep noise attack and sharp decay.
 
 An internal audio buffer,, is continually resampled at the Resampling Frequency 
 and the resulting output is multiplied by the amplitude. Parallel with the sampling, 
 the buffer is smoothed to simulate the effect of natural decay.
 */

@interface OCSPluckDrum : OCSParameter

/// @name Properties

/// @name Initialization

/// Initializes the drum with given parameters
/// @param amplitude           The output amplitude.
/// @param resamplingFrequency The resampling frequency in cycles-per-second.
/// @param pitchDecayFrequency Intended pitch value in Hz, used to set up a buffer of 1 cycle of audio samples which will be smoothed over time by a chosen decay method.  Normally anticipates the resampling frequency, but may be set artificially high or low to influence the size of the sample buffer.
/// @param audioBuffer        The output of a function table used to initialize the cyclic decay buffer. If set to zero, a random sequence will be used instead.
/// @param roughnessFactor     Zero gives the plucked string effect, while 1 reverses the polarity of every sample (octave down, odd harmonics). The setting .5 gives an optimum snare drum.
/// @param stretchFactor       Must be greater than or equal to 1.
- (id)initWithAmplitude:(OCSControl *)amplitude
    resamplingFrequency:(OCSControl *)resamplingFrequency
    pitchDecayFrequency:(OCSConstant *)pitchDecayFrequency
            audioBuffer:(OCSConstant *)audioBuffer
        roughnessFactor:(OCSConstant *)roughnessFactor
          stretchFactor:(OCSConstant *)stretchFactor;

@end
