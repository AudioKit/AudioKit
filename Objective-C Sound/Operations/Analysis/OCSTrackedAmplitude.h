//
//  OCSTrackedAmplitude.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 11/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParameter+Operation.h"
#import "OCSAudio.h"

@interface OCSTrackedAmplitude : OCSControl

/// Initialize the tracked amplitude.
/// @param audioSource Input signal.
/// @param hopsize  Size of the analysis 'hop', in samples, required to be power-of-two (min 64, max 4096). This is the period between measurements.
- (id)initWithAudioSource:(OCSAudio *)audioSource
               sampleSize:(OCSConstant *)hopSize;

/// Set the optional number of spectral peaks
/// @param numberOfSpectralPeaks Number of spectral peaks to use in the analysis, defaults to 20.
- (void)setOptionalSpectralPeaks:(OCSConstant *)numberOfSpectralPeaks;


@end
