//
//  AKWarpedFFT.h
//  AudioKit
//
//  Auto-generated on 3/29/13.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKFSignal.h"
#import "AKParameter+Operation.h"

/** Warp the spectral envelope of a PVS signal by means of shifting and scaling.

 Warp the spectral envelope of a PVS signal by means of shifting and scaling.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKWarpedFFT : AKFSignal

/// Instantiates the warp
/// @param sourceSignal Input Stream
/// @param scalingRatio Spectral envelope scaling ratio. Values > 1 stretch the envelope and < 1 compress it.
/// @param shift Spectral envelope shift, values > 0 shift the envelope linearly upwards and values < 1 shift it downwards.
- (instancetype)initWithInput:(AKFSignal *)sourceSignal
                 scalingRatio:(AKControl *)scalingRatio
                        shift:(AKControl *)shift;

/// Set an optional low frequency
/// @param lowFrequency Lowest frequency shifted, defaults to zero.
- (void)setOptionalLowFrequency:(AKControl *)lowFrequency;

/// Set an optional extraction method
/// @param extractionMethod Spectral envelope extraction method 1: liftered cepstrum method (default); 2: true envelope method (defaults to 1).
- (void)setOptionalExtractionMethod:(AKControl *)extractionMethod;

/// Set an optional gain
/// @param gain Amplitude Scaling (defaults to 1)
- (void)setOptionalGain:(AKControl *)gain;

/// Set an optional number of coefficients
/// @param numberOfCoefficients Number of cepstrum coefs used in formant preservation (defaults to 80).
- (void)setOptionalNumberOfCoefficients:(AKControl *)numberOfCoefficients;


@end
NS_ASSUME_NONNULL_END
