//
//  OCSWarp.h
//  Objective-C Sound
//
//  Auto-generated from database on 3/29/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFSignal.h"
#import "OCSParameter+Operation.h"

/** Warp the spectral envelope of a PVS signal by means of shifting and scaling.
 
 Warp the spectral envelope of a PVS signal by means of shifting and scaling.
 */

@interface OCSWarp : OCSFSignal

/// Instantiates the warp
/// @param sourceSignal Input Stream
/// @param scalingRatio Spectral envelope scaling ratio. Values > 1 stretch the envelope and < 1 compress it.
/// @param shift Spectral envelope shift, values > 0 shift the envelope linearly upwards and values < 1 shift it downwards.
- (id)initWithSourceSignal:(OCSFSignal *)sourceSignal
              scalingRatio:(OCSControl *)scalingRatio
                     shift:(OCSControl *)shift;


/// Set an optional low frequency
/// @param lowFrequency Lowest frequency shifted, defaults to zero.
- (void)setOptionalLowFrequency:(OCSControl *)lowFrequency;

/// Set an optional extraction method
/// @param extractionMethod Spectral envelope extraction method 1: liftered cepstrum method (default); 2: true envelope method (defaults to 1).
- (void)setOptionalExtractionMethod:(OCSControl *)extractionMethod;

/// Set an optional gain
/// @param gain Amplitude Scaling (defaults to 1)
- (void)setOptionalGain:(OCSControl *)gain;

/// Set an optional number of coefficients
/// @param numberOfCoefficients Number of cepstrum coefs used in formant preservation (defaults to 80).
- (void)setOptionalNumberOfCoefficients:(OCSControl *)numberOfCoefficients;


@end