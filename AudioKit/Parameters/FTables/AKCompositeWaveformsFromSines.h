//
//  AKCompositeWaveformsFromSines.h
//  AudioKit
//
//  Created by Adam Boulanger on 10/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKFTable.h"

/** Generates composite waveforms made up of weighted sums of sinusoids.
 */

@interface AKCompositeWaveformsFromSines : AKFTable

/// Instantiates a composite waveform of weighted sinusoids from separate arrays describing parital properties.  Arrays must be equal in length.
/// @param tableSize    Number of points in the table. Must be a power of 2 or power-of-2 plus 1.
/// @param partialNumbers Array containing partial numbers (relative to a fundamental that would occupy tableSize locations per cycle) of sinusoid a, sinusoid b, etc. Must contain positive values, but need not be a whole numbers, i.e., non-harmonic partials are permitted. Partials may be in any order.
/// @param partialStrengths Array containing strengths of partials pna, pnb, etc. These are relative strengths, since the composite waveform may be rescaled later. Negative values are permitted and imply a 180 degree phase shift.
/// @param partialOffsets Array of DC offset of partials pna, pnb, etc. This is applied after strength scaling, i.e. a value of 2 will lift a 2-strength sinusoid from range [-2,2] to range [0,4] (before later rescaling).
/// @param partialPhases Array of initial phase of partials pna, pnb, etc., expressed in degrees.
- (instancetype)initWithTableSize:(int)tableSize
                   partialNumbers:(AKArray *)partialNumbers
                 partialStrengths:(AKArray *)partialStrengths
           partialStrengthOffsets:(AKArray *)partialOffsets
                    partialPhases:(AKArray *)partialPhases;

@end
