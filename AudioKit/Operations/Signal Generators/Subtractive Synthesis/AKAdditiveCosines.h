//
//  AKAdditiveCosines.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/14/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//


#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A set of harmonically related cosine partials.

 More detailed description from http://www.csounds.com/manual/html/
 */

@interface AKAdditiveCosines : AKAudio

/// Instantiates the additive cosines with all values
/// @param cosineTable A cosine table with at least 8192 points is recommended.
/// @param harmonicsCount Total number of harmonics requested.
/// @param firstHarmonicIndex The lowest harmonic present.
/// @param partialMultiplier The multiplier in the series of amplitude coefficients.
/// @param fundamentalFrequency The fundamental frequency which can be modulated at any rate.
/// @param amplitude The total amplitude of the output of all the cosines.
/// @param phase Initial phase of the fundamental frequency, expressed as a fraction of a cycle (0 to 1).
- (instancetype)initWithCosineTable:(AKFTable *)cosineTable
                     harmonicsCount:(AKControl *)harmonicsCount
                 firstHarmonicIndex:(AKControl *)firstHarmonicIndex
                  partialMultiplier:(AKControl *)partialMultiplier
               fundamentalFrequency:(AKParameter *)fundamentalFrequency
                          amplitude:(AKParameter *)amplitude
                              phase:(AKConstant *)phase;


/// Instantiates the additive cosines with default values
/// @param cosineTable A cosine table with at least 8192 points is recommended.
- (instancetype)initWithCosineTable:(AKFTable *)cosineTable;


/// Instantiates the additive cosines with default values
/// @param cosineTable A cosine table with at least 8192 points is recommended.
+ (instancetype)audioWithCosineTable:(AKFTable *)cosineTable;




/// Total number of harmonics requested. [Default Value: 10]
@property AKControl *harmonicsCount;

/// Set an optional harmonics count
/// @param harmonicsCount Total number of harmonics requested. [Default Value: 10]
- (void)setOptionalHarmonicsCount:(AKControl *)harmonicsCount;


/// The lowest harmonic present. [Default Value: 1]
@property AKControl *firstHarmonicIndex;

/// Set an optional first harmonic index
/// @param firstHarmonicIndex The lowest harmonic present. [Default Value: 1]
- (void)setOptionalFirstHarmonicIndex:(AKControl *)firstHarmonicIndex;


/// The multiplier in the series of amplitude coefficients. [Default Value: 0.5]
@property AKControl *partialMultiplier;

/// Set an optional partial multiplier
/// @param partialMultiplier The multiplier in the series of amplitude coefficients. [Default Value: 0.5]
- (void)setOptionalPartialMultiplier:(AKControl *)partialMultiplier;


/// The fundamental frequency which can be modulated at any rate. [Default Value: 220]
@property AKParameter *fundamentalFrequency;

/// Set an optional fundamental frequency
/// @param fundamentalFrequency The fundamental frequency which can be modulated at any rate. [Default Value: 220]
- (void)setOptionalFundamentalFrequency:(AKParameter *)fundamentalFrequency;


/// The total amplitude of the output of all the cosines. [Default Value: 1]
@property AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude The total amplitude of the output of all the cosines. [Default Value: 1]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;


/// Initial phase of the fundamental frequency, expressed as a fraction of a cycle (0 to 1). [Default Value: 0]
@property AKConstant *phase;

/// Set an optional phase
/// @param phase Initial phase of the fundamental frequency, expressed as a fraction of a cycle (0 to 1). [Default Value: 0]
- (void)setOptionalPhase:(AKConstant *)phase;


@end
