//
//  AKHarmonicCosineTableGenerator.h
//  AudioKit
//
//  Auto-generated on 12/14/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKTableGenerator.h"

/** Generates an additive set of cosine partials
 
 This table generates an additive set of cosine partials, in the manner of the AKAdditiveCosines operation
 */

@interface AKHarmonicCosineTableGenerator : AKTableGenerator

/// Instantiates the additive cosine table with all values defined
/// @param numberOfHarmonics Number of harmonics in the partial series.
/// @param lowestHarmonic Lowest harmonic partial present. Can be positive, zero or negative. The set of partials can begin at any partial number and proceeds upwards; if this is negative, all partials below zero will reflect in zero to produce positive partials without phase change (since cosine is an even function), and will add constructively to any positive partials in the set.
/// @param partialMultiplier Multiplier in an amplitude coefficient series.  This is a power series: if the lhth partial has a strength coefficient of A the (lowestHarmonic + n)th partial will have a coefficient of A * r^n, i.e. strength values trace an exponential curve. May be positive, zero or negative, and is not restricted to integers.
- (instancetype)initWithNumberOfHarmonics:(int)numberOfHarmonics
                           lowestHarmonic:(int)lowestHarmonic
                        partialMultiplier:(float)partialMultiplier;

/// Instantiates the additive cosine table with default values
- (instancetype)init;

/// Number of harmonics in the partial series. [Default Value: 1]
@property int numberOfHarmonics;

/// Set an optional number of harmonics
/// @param numberOfHarmonics Number of harmonics in the partial series. [Default Value: 1]
- (void)setOptionalNumberOfHarmonics:(int)numberOfHarmonics;


/// Lowest harmonic partial present. Can be positive, zero or negative. The set of partials can begin at any partial number and proceeds upwards; if this is negative, all partials below zero will reflect in zero to produce positive partials without phase change (since cosine is an even function), and will add constructively to any positive partials in the set. [Default Value: 1]
@property int lowestHarmonic;

/// Set an optional lowest harmonic
/// @param lowestHarmonic Lowest harmonic partial present. Can be positive, zero or negative. The set of partials can begin at any partial number and proceeds upwards; if this is negative, all partials below zero will reflect in zero to produce positive partials without phase change (since cosine is an even function), and will add constructively to any positive partials in the set. [Default Value: 1]
- (void)setOptionalLowestHarmonic:(int)lowestHarmonic;


/// Multiplier in an amplitude coefficient series.  This is a power series: if the lhth partial has a strength coefficient of A the (lowestHarmonic + n)th partial will have a coefficient of A * r^n, i.e. strength values trace an exponential curve. May be positive, zero or negative, and is not restricted to integers. [Default Value: 1]
@property float partialMultiplier;

/// Set an optional partial multiplier
/// @param partialMultiplier Multiplier in an amplitude coefficient series.  This is a power series: if the lhth partial has a strength coefficient of A the (lowestHarmonic + n)th partial will have a coefficient of A * r^n, i.e. strength values trace an exponential curve. May be positive, zero or negative, and is not restricted to integers. [Default Value: 1]
- (void)setOptionalPartialMultiplier:(float)partialMultiplier;

@end
