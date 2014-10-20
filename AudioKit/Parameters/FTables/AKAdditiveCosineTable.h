//
//  AKAdditiveCosineTable.h
//  AudioKit
//
//  Created by Adam Boulanger on 10/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKFTable.h"

/** Generates an additive set of cosine partials.
 */
@interface AKAdditiveCosineTable : AKFTable

/// Creates a pure cosine table with 1 harmonic (the fundamental).
- (instancetype)init;

/// Creates an additive set of cosine partials with a given total number of harmonics.
/// @param tableSize             Number of points in the table. Must be a power of 2 or power-of-2 plus 1.
/// @param numberOfHarmonics     Number of harmonics in the partial series.
- (instancetype)initWithSize:(int)tableSize
           numberOfHarmonics:(int)numberOfHarmonics;

/// Creates an additive set of cosine partials with a given total number of harmonics and lowest harmonic.
/// @param tableSize             Number of points in the table. Must be a power of 2 or power-of-2 plus 1.
/// @param numberOfHarmonics     Number of harmonics in the partial series.
/// @param lowestHarmonic        Number of lowers harmonic in partial series.  If negative, all negative partials will reflect about zero and add constructively to positive partials.
- (instancetype)initWithSize:(int)tableSize
           numberOfHarmonics:(int)numberOfHarmonics
              lowestHarmonic:(int)lowestHarmonic;

/// Creates an additive set of cosine partials with a given total number of harmonics and lowest harmonic.
/// @param tableSize             Number of points in the table. Must be a power of 2 or power-of-2 plus 1.
/// @param numberOfHarmonics     Number of harmonics in the partial series.
/// @param lowestHarmonic        Number of lowers harmonic in partial series.  If negative, all negative partials will reflect about zero and add constructively to positive partials.
/// @param partialMultiplier     Multiplier by which to scale partials in the harmonic series.  If the lowest harmonic (lh) has amplitude "A" then the (lh + n)th harmonic will have a coefficient of A*(partialMultiplier ** n).
- (instancetype)initWithSize:(int)tableSize
           numberOfHarmonics:(int)numberOfHarmonics
              lowestHarmonic:(int)lowestHarmonic
           partialMultiplier:(int)partialMultiplier;

@end
