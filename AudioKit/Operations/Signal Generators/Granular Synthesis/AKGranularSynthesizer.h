//
//  AKGranularSynthesizer.h
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Customized by Aurelius Prochazka to deal with window waveform.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Generate granular synthesis textures with user control.


 */

NS_ASSUME_NONNULL_BEGIN
@interface AKGranularSynthesizer : AKAudio
/// Instantiates the granular synthesizer with all values
/// @param grainWaveform Table contain grain waveform. Updated at Control-rate.
/// @param frequency Grain frequency in Hz Updated at Control-rate. [Default Value: ]
/// @param windowWaveform Table containing window waveform. [Default Value: AKWindowTypeHamming]
/// @param duration Grain duration in seconds. It also controls the duration of already active grains (actually the speed at which the window function is read). Updated at Control-rate. [Default Value: 0.2]
/// @param density Number of grains per second. Updated at Control-rate. [Default Value: 200]
/// @param maximumOverlappingGrains The maximum number of overlapping grains. [Default Value: 200]
/// @param frequencyVariation Random bipolar variation in grain frequency in Hz. Updated at Control-rate. [Default Value: 0]
/// @param frequencyVariationDistribution This value controls the distribution of grain frequency variation. If this is positive, the random distribution (x is in the range -1 to 1) isabs(x) ^ ((1 / parameter) - 1)  For negative parameter values, it is (1 - abs(x)) ^ ((-1 / parameter) - 1) Setting this parameter to -1, 0, or 1 will result in uniform distribution (this is also faster to calculate).  Updated at Control-rate. [Default Value: 0]
/// @param phase Grain phase. This is the location in the grain waveform table, expressed as a fraction (between 0 to 1) of the table length. Updated at Control-rate. [Default Value: 0.5]
/// @param startPhaseVariation Random variation (bipolar) in start phase Updated at Control-rate. [Default Value: 0.5]
/// @param prpow Distribution of random phase variation. Updated at Control-rate. [Default Value: 0]
- (instancetype)initWithGrainWaveform:(AKTable *)grainWaveform
                            frequency:(AKParameter *)frequency
                       windowWaveform:(AKTable *)windowWaveform
                             duration:(AKParameter *)duration
                              density:(AKParameter *)density
             maximumOverlappingGrains:(AKConstant *)maximumOverlappingGrains
                   frequencyVariation:(AKParameter *)frequencyVariation
       frequencyVariationDistribution:(AKParameter *)frequencyVariationDistribution
                                phase:(AKParameter *)phase
                  startPhaseVariation:(AKParameter *)startPhaseVariation
                                prpow:(AKParameter *)prpow;

/// Instantiates the granular synthesizer with default values
/// @param grainWaveform Table contain grain waveform.
/// @param frequency Grain frequency in Hz
- (instancetype)initWithGrainWaveform:(AKTable *)grainWaveform
                            frequency:(AKParameter *)frequency;

/// Instantiates the granular synthesizer with default values
/// @param grainWaveform Table contain grain waveform.
/// @param frequency Grain frequency in Hz
+ (instancetype)WithGrainWaveform:(AKTable *)grainWaveform
                        frequency:(AKParameter *)frequency;

/// Table containing window waveform. [Default Value: AKWindowTypeHamming]
@property (nonatomic) AKTable *windowWaveform;

/// Set an optional window waveform
/// @param windowWaveform Table containing window waveform. [Default Value: AKWindowTypeHamming]
- (void)setOptionalWindowWaveform:(AKTable *)windowWaveform;

/// Grain duration in seconds. It also controls the duration of already active grains (actually the speed at which the window function is read). [Default Value: 0.2]
@property (nonatomic) AKParameter *duration;

/// Set an optional duration
/// @param duration Grain duration in seconds. It also controls the duration of already active grains (actually the speed at which the window function is read). Updated at Control-rate. [Default Value: 0.2]
- (void)setOptionalDuration:(AKParameter *)duration;

/// Number of grains per second. [Default Value: 200]
@property (nonatomic) AKParameter *density;

/// Set an optional density
/// @param density Number of grains per second. Updated at Control-rate. [Default Value: 200]
- (void)setOptionalDensity:(AKParameter *)density;

/// The maximum number of overlapping grains. [Default Value: 200]
@property (nonatomic) AKConstant *maximumOverlappingGrains;

/// Set an optional maximum overlapping grains
/// @param maximumOverlappingGrains The maximum number of overlapping grains. [Default Value: 200]
- (void)setOptionalMaximumOverlappingGrains:(AKConstant *)maximumOverlappingGrains;

/// Random bipolar variation in grain frequency in Hz. [Default Value: 0]
@property (nonatomic) AKParameter *frequencyVariation;

/// Set an optional frequency variation
/// @param frequencyVariation Random bipolar variation in grain frequency in Hz. Updated at Control-rate. [Default Value: 0]
- (void)setOptionalFrequencyVariation:(AKParameter *)frequencyVariation;

/// This value controls the distribution of grain frequency variation. If this is positive, the random distribution (x is in the range -1 to 1) isabs(x) ^ ((1 / parameter) - 1)  For negative parameter values, it is (1 - abs(x)) ^ ((-1 / parameter) - 1) Setting this parameter to -1, 0, or 1 will result in uniform distribution (this is also faster to calculate).  [Default Value: 0]
@property (nonatomic) AKParameter *frequencyVariationDistribution;

/// Set an optional frequency variation distribution
/// @param frequencyVariationDistribution This value controls the distribution of grain frequency variation. If this is positive, the random distribution (x is in the range -1 to 1) isabs(x) ^ ((1 / parameter) - 1)  For negative parameter values, it is (1 - abs(x)) ^ ((-1 / parameter) - 1) Setting this parameter to -1, 0, or 1 will result in uniform distribution (this is also faster to calculate).  Updated at Control-rate. [Default Value: 0]
- (void)setOptionalFrequencyVariationDistribution:(AKParameter *)frequencyVariationDistribution;

/// Grain phase. This is the location in the grain waveform table, expressed as a fraction (between 0 to 1) of the table length. [Default Value: 0.5]
@property (nonatomic) AKParameter *phase;

/// Set an optional phase
/// @param phase Grain phase. This is the location in the grain waveform table, expressed as a fraction (between 0 to 1) of the table length. Updated at Control-rate. [Default Value: 0.5]
- (void)setOptionalPhase:(AKParameter *)phase;

/// Random variation (bipolar) in start phase [Default Value: 0.5]
@property (nonatomic) AKParameter *startPhaseVariation;

/// Set an optional start phase variation
/// @param startPhaseVariation Random variation (bipolar) in start phase Updated at Control-rate. [Default Value: 0.5]
- (void)setOptionalStartPhaseVariation:(AKParameter *)startPhaseVariation;

/// Distribution of random phase variation. [Default Value: 0]
@property (nonatomic) AKParameter *prpow;

/// Set an optional prpow
/// @param prpow Distribution of random phase variation. Updated at Control-rate. [Default Value: 0]
- (void)setOptionalPrpow:(AKParameter *)prpow;



@end
NS_ASSUME_NONNULL_END
