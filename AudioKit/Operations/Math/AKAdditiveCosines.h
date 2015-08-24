//
//  AKAdditiveCosines.h
//  AudioKit
//
//  Auto-generated on 2/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A set of harmonically related cosine partials.

 More detailed description from http://www.csounds.com/manual/html/
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKAdditiveCosines : AKAudio
/// Instantiates the additive cosines with all values
/// @param cosineTable A cosine table with at least 8192 points is recommended. 
/// @param harmonicsCount Total number of harmonics requested. Updated at Control-rate. [Default Value: 10]
/// @param firstHarmonicIndex The lowest harmonic present. Updated at Control-rate. [Default Value: 1]
/// @param partialMultiplier The multiplier in the series of amplitude coefficients. Updated at Control-rate. [Default Value: 1]
/// @param fundamentalFrequency The fundamental frequency which can be modulated at any rate. [Default Value: 220]
/// @param amplitude The total amplitude of the output of all the cosines. [Default Value: 1]
/// @param phase Initial phase of the fundamental frequency, expressed as a fraction of a cycle (0 to 1). [Default Value: 0]
- (instancetype)initWithCosineTable:(AKTable *)cosineTable
                     harmonicsCount:(AKParameter *)harmonicsCount
                 firstHarmonicIndex:(AKParameter *)firstHarmonicIndex
                  partialMultiplier:(AKParameter *)partialMultiplier
               fundamentalFrequency:(AKParameter *)fundamentalFrequency
                          amplitude:(AKParameter *)amplitude
                              phase:(AKConstant *)phase;

/// Instantiates the additive cosines with default values
/// @param cosineTable A cosine table with at least 8192 points is recommended.
- (instancetype)initWithCosineTable:(AKTable *)cosineTable;

/// Instantiates the additive cosines with default values
/// @param cosineTable A cosine table with at least 8192 points is recommended.
+ (instancetype)cosinesWithCosineTable:(AKTable *)cosineTable;

/// Total number of harmonics requested. [Default Value: 10]
@property (nonatomic) AKParameter *harmonicsCount;

/// Set an optional harmonics count
/// @param harmonicsCount Total number of harmonics requested. Updated at Control-rate. [Default Value: 10]
- (void)setOptionalHarmonicsCount:(AKParameter *)harmonicsCount;

/// The lowest harmonic present. [Default Value: 1]
@property (nonatomic) AKParameter *firstHarmonicIndex;

/// Set an optional first harmonic index
/// @param firstHarmonicIndex The lowest harmonic present. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalFirstHarmonicIndex:(AKParameter *)firstHarmonicIndex;

/// The multiplier in the series of amplitude coefficients. [Default Value: 1]
@property (nonatomic) AKParameter *partialMultiplier;

/// Set an optional partial multiplier
/// @param partialMultiplier The multiplier in the series of amplitude coefficients. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalPartialMultiplier:(AKParameter *)partialMultiplier;

/// The fundamental frequency which can be modulated at any rate. [Default Value: 220]
@property (nonatomic) AKParameter *fundamentalFrequency;

/// Set an optional fundamental frequency
/// @param fundamentalFrequency The fundamental frequency which can be modulated at any rate. [Default Value: 220]
- (void)setOptionalFundamentalFrequency:(AKParameter *)fundamentalFrequency;

/// The total amplitude of the output of all the cosines. [Default Value: 1]
@property (nonatomic) AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude The total amplitude of the output of all the cosines. [Default Value: 1]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;

/// Initial phase of the fundamental frequency, expressed as a fraction of a cycle (0 to 1). [Default Value: 0]
@property (nonatomic) AKConstant *phase;

/// Set an optional phase
/// @param phase Initial phase of the fundamental frequency, expressed as a fraction of a cycle (0 to 1). [Default Value: 0]
- (void)setOptionalPhase:(AKConstant *)phase;



@end
NS_ASSUME_NONNULL_END
