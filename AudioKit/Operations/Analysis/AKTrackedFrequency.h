//
//  AKTrackedFrequency.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/12/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKParameter+Operation.h"
#import "AKAudio.h"

/** Tracks the pitch of a signal.
 
 Takes an input signal, splits it into hopSize blocks and using a STFT method,
 extracts an estimated pitch for its fundamental frequency as well as estimating the
 total amplitude of the signal in dB, relative to full-scale (0dB). The method
 implies an analysis window size of 2*hopSize samples (overlaping by 1/2 window),
 which has to be a power-of-two, between 128 and 8192 (hopsizes between 64 and 4096).
 Smaller windows will give better time precision, but worse frequency accuracy
 (esp. in low fundamentals).
 
 Based on an original algorithm by M. Puckette.
 
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKTrackedFrequency : AKControl

/// Initialize the tracked frequency.
/// @param input Input signal.
/// @param hopSize  Size of the analysis 'hop', in samples, required to be power-of-two (min 64, max 4096). This is the period between measurements.
- (instancetype)initWithInput:(AKAudio *)input
                   sampleSize:(AKConstant *)hopSize;

/// Set the optional number of spectral peaks
/// @param numberOfSpectralPeaks Number of spectral peaks to use in the analysis, defaults to 20.
- (void)setOptionalSpectralPeaks:(AKConstant *)numberOfSpectralPeaks;

@end
NS_ASSUME_NONNULL_END
