//
//  AKWeightedSumOfSinusoids.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKFunctionTable.h"

/** Generates composite waveforms made up of weighted sums of simple sinusoids.
 */
@interface AKWeightedSumOfSinusoids : AKFunctionTable

/// Creates a pure sine wave with a default size of 4096.
- (instancetype)init;

/// Creates a pure sine wave with a default size of 4096.
+ (instancetype)pureSineWave;

/// Creates a sine table with an array of partial strengths
/// @param size             Number of points in the table. Must be a power of 2 or power-of-2 plus 1.
/// @param partialStrengthsArray Relative strengths of the fixed harmonic partial numbers 1,2,3, etc. Partials not required should be given a strength of zero.
- (instancetype)initWithSize:(int)size
            partialStrengths:(AKArray *)partialStrengthsArray;



@end
