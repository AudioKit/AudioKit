//
//  AKHilbertTransformer.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/30/12.
//  Modified by Aurelius Prochazka on 12/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKStereoAudio.h"
#import "AKParameter+Operation.h"

/** An IIR implementation of a Hilbert transformer.
 
 AKHilbertTransformer is an IIR filter based implementation of a broad-band 90 degree phase difference network. The input to AKHilbertTransformer is an audio signal, with a frequency range from 15 Hz to 15 kHz. The outputs of AKHilbertTransformer have an identical frequency response to the input (i.e. they sound the same), but the two outputs have a constant phase difference of 90 degrees, plus or minus some small amount of error, throughout the entire frequency range. The outputs are in quadrature.
 AKHilbertTransformer is useful in the implementation of many digital signal processing techniques that require a signal in phase quadrature. ar1 corresponds to the cosine output of AKHilbertTransformer, while ar2 corresponds to the sine output. The two outputs have a constant phase difference throughout the audio range that corresponds to the phase relationship between cosine and sine waves.
 Internally, AKHilbertTransformer is based on two parallel 6th-order allpass filters. Each allpass filter implements a phase lag that increases with frequency; the difference between the phase lags of the parallel allpass filters at any given point is approximately 90 degrees.
 Unlike an FIR-based Hilbert Transformer, the output of AKHilbertTransformer does not have a linear phase response. However, the IIR structure used in AKHilbertTransformer is far more efficient to compute, and the nonlinear phase response can be used in the creation of interesting audio effects.
 */

@interface AKHilbertTransformer : AKStereoAudio

/// Instantiates the hilbert transformer
/// @param audioSource The Input Signal
- (instancetype)initWithAudioSource:(AKAudio *)audioSource;

/// Helper functions to pull apart the stereo audio output appropriately.
- (AKAudio *)realPart;
- (AKAudio *)imaginaryPart;
- (AKAudio *)sineOutput;
- (AKAudio *)cosineOutput;

@end