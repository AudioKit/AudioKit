//
//  AKFourierSeriesTableGenerator.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTableGenerator.h"

/** Generates composite waveforms made up of weighted sums of simple sinusoids.
 */
@interface AKFourierSeriesTableGenerator : AKTableGenerator


/// Creates a Fourier Series with no elements.
- (instancetype)init;

/// Add a sinusoid.  Partials may be in any order.
/// @param partialNumber Partial number (relative to a fundamental that would occupy size locations per cycle) of sinusod. Must be positive, but need not be a whole number, i.e., non-harmonic partials are permitted.
/// @param partialStrength Relative strength of the partial, since the composite waveform may be rescaled later. Negative values are permitted and imply a 180 degree phase shift.
- (void)addSinusoidWithPartialNumber:(float)partialNumber
                            strength:(float)partialStrength;

/// Add a sinusoid.  Partials may be in any order.
/// @param partialNumber Partial number (relative to a fundamental that would occupy size locations per cycle) of sinusod. Must be positive, but need not be a whole number, i.e., non-harmonic partials are permitted.
/// @param strength Relative strength of the partial, since the composite waveform may be rescaled later. Negative values are permitted and imply a 180 degree phase shift.
/// @param phase Initial phase of the partial, expressed in degrees.
/// @param dcOffset DC offset of partial., e This is applied after strength scaling, i.e. a value of 2 will lift a 2-strength sinusoid from range [-2,2] to range [0,4] (before later rescaling).
- (void)addSinusoidWithPartialNumber:(int)partialNumber
                            strength:(float)strength
                               phase:(float)phase
                            dcOffset:(float)dcOffset;


@end
