//
//  AKGranularSynthesisTexture.h
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Generates granular synthesis textures.


 */

NS_ASSUME_NONNULL_BEGIN
@interface AKGranularSynthesisTexture : AKAudio
/// Instantiates the granular synthesis texture with all values
/// @param grainTable The grain waveform. This can be just a sine wave or a sampled sound.
/// @param windowTable The amplitude envelope used for the grains. 
/// @param maximumGrainDuration Maximum grain duration in seconds. [Default Value: 0.5]
/// @param averageGrainDuration Average grain duration in seconds. Updated at Control-rate. [Default Value: 0.4]
/// @param maximumFrequencyDeviation Maximum pitch deviation from grainFrequency in Hz. Updated at Control-rate. [Default Value: 0.5]
/// @param grainFrequency To use the original frequency of the input sound, divide the original sample rate of the grain waveform by the length of the grain table. [Default Value: 0.8]
/// @param maximumAmplitudeDeviation Maximum amplitude deviation from `amplitude`. If it is set to zero then there is no random amplitude for each grain. Updated at Control-rate. [Default Value: 0.1]
/// @param grainAmplitude Amplitude of each grain. [Default Value: 0.01]
/// @param grainDensity Density of grains measured in grains per second. If this is constant then the output is synchronous granular synthesis. If grainDensity has a random element (like added noise), then the result is more like asynchronous granular synthesis. [Default Value: 500]
/// @param useRandomGrainOffset Whether or not to set the grains to start at the initial position or a random position [Default Value: true]
- (instancetype)initWithGrainTable:(AKTable *)grainTable
                       windowTable:(AKTable *)windowTable
              maximumGrainDuration:(AKConstant *)maximumGrainDuration
              averageGrainDuration:(AKParameter *)averageGrainDuration
         maximumFrequencyDeviation:(AKParameter *)maximumFrequencyDeviation
                    grainFrequency:(AKParameter *)grainFrequency
         maximumAmplitudeDeviation:(AKParameter *)maximumAmplitudeDeviation
                    grainAmplitude:(AKParameter *)grainAmplitude
                      grainDensity:(AKParameter *)grainDensity
              useRandomGrainOffset:(BOOL)useRandomGrainOffset;

/// Instantiates the granular synthesis texture with default values
/// @param grainTable The grain waveform. This can be just a sine wave or a sampled sound.
/// @param windowTable The amplitude envelope used for the grains.
- (instancetype)initWithGrainTable:(AKTable *)grainTable
                       windowTable:(AKTable *)windowTable;

/// Instantiates the granular synthesis texture with default values
/// @param grainTable The grain waveform. This can be just a sine wave or a sampled sound.
/// @param windowTable The amplitude envelope used for the grains.
+ (instancetype)textureWithGrainTable:(AKTable *)grainTable
                          windowTable:(AKTable *)windowTable;

/// Maximum grain duration in seconds. [Default Value: 0.5]
@property (nonatomic) AKConstant *maximumGrainDuration;

/// Set an optional maximum grain duration
/// @param maximumGrainDuration Maximum grain duration in seconds. [Default Value: 0.5]
- (void)setOptionalMaximumGrainDuration:(AKConstant *)maximumGrainDuration;

/// Average grain duration in seconds. [Default Value: 0.4]
@property (nonatomic) AKParameter *averageGrainDuration;

/// Set an optional average grain duration
/// @param averageGrainDuration Average grain duration in seconds. Updated at Control-rate. [Default Value: 0.4]
- (void)setOptionalAverageGrainDuration:(AKParameter *)averageGrainDuration;

/// Maximum pitch deviation from grainFrequency in Hz. [Default Value: 0.5]
@property (nonatomic) AKParameter *maximumFrequencyDeviation;

/// Set an optional maximum frequency deviation
/// @param maximumFrequencyDeviation Maximum pitch deviation from grainFrequency in Hz. Updated at Control-rate. [Default Value: 0.5]
- (void)setOptionalMaximumFrequencyDeviation:(AKParameter *)maximumFrequencyDeviation;

/// To use the original frequency of the input sound, divide the original sample rate of the grain waveform by the length of the grain table. [Default Value: 0.8]
@property (nonatomic) AKParameter *grainFrequency;

/// Set an optional grain frequency
/// @param grainFrequency To use the original frequency of the input sound, divide the original sample rate of the grain waveform by the length of the grain table. [Default Value: 0.8]
- (void)setOptionalGrainFrequency:(AKParameter *)grainFrequency;

/// Maximum amplitude deviation from `amplitude`. If it is set to zero then there is no random amplitude for each grain. [Default Value: 0.1]
@property (nonatomic) AKParameter *maximumAmplitudeDeviation;

/// Set an optional maximum amplitude deviation
/// @param maximumAmplitudeDeviation Maximum amplitude deviation from `amplitude`. If it is set to zero then there is no random amplitude for each grain. Updated at Control-rate. [Default Value: 0.1]
- (void)setOptionalMaximumAmplitudeDeviation:(AKParameter *)maximumAmplitudeDeviation;

/// Amplitude of each grain. [Default Value: 0.01]
@property (nonatomic) AKParameter *grainAmplitude;

/// Set an optional grain amplitude
/// @param grainAmplitude Amplitude of each grain. [Default Value: 0.01]
- (void)setOptionalGrainAmplitude:(AKParameter *)grainAmplitude;

/// Density of grains measured in grains per second. If this is constant then the output is synchronous granular synthesis. If grainDensity has a random element (like added noise), then the result is more like asynchronous granular synthesis. [Default Value: 500]
@property (nonatomic) AKParameter *grainDensity;

/// Set an optional grain density
/// @param grainDensity Density of grains measured in grains per second. If this is constant then the output is synchronous granular synthesis. If grainDensity has a random element (like added noise), then the result is more like asynchronous granular synthesis. [Default Value: 500]
- (void)setOptionalGrainDensity:(AKParameter *)grainDensity;

/// Whether or not to set the grains to start at the initial position or a random position [Default Value: true]
@property (nonatomic) BOOL useRandomGrainOffset;

/// Set an optional use random grain offset
/// @param useRandomGrainOffset Whether or not to set the grains to start at the initial position or a random position [Default Value: true]
- (void)setOptionalUseRandomGrainOffset:(BOOL)useRandomGrainOffset;



@end
NS_ASSUME_NONNULL_END
