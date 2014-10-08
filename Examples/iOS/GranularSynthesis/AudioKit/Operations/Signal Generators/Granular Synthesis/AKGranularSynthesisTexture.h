//
//  AKGranularSynthesisTexture.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 8/3/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Generates granular synthesis textures.

 
 */

@interface AKGranularSynthesisTexture : AKAudio

/// Instantiates the ranular synthesis texture
/// @param grainFTable The grain waveform. This can be just a sine wave or a sampled sound.
/// @param windowFTable The amplitude envelope used for the grains.
/// @param maximumGrainDuration Maximum grain duration in seconds.
/// @param averageGrainDuration Average grain duration in seconds.
/// @param maximumFrequencyDeviation Maximum pitch deviation from grainFrequency in Hz.
/// @param grainFrequency To use the original frequency of the input sound, divide the original sample rate of the grain waveform by the length of the grain function table.
/// @param maximumAmplitudeDeviation Maximum amplitude deviation from `amplitude`. If it is set to zero then there is no random amplitude for each grain.
/// @param grainAmplitude Amplitude of each grain.
/// @param grainDensity Density of grains measured in grains per second. If this is constant then the output is synchronous granular synthesis. If grainDensity has a random element (like added noise), then the result is more like asynchronous granular synthesis.
- (instancetype)initWithGrainFTable:(AKConstant *)grainFTable
                       windowFTable:(AKConstant *)windowFTable
               maximumGrainDuration:(AKConstant *)maximumGrainDuration
               averageGrainDuration:(AKControl *)averageGrainDuration
          maximumFrequencyDeviation:(AKControl *)maximumFrequencyDeviation
                     grainFrequency:(AKParameter *)grainFrequency
          maximumAmplitudeDeviation:(AKControl *)maximumAmplitudeDeviation
                     grainAmplitude:(AKParameter *)grainAmplitude
                       grainDensity:(AKParameter *)grainDensity;


/// Set an optional use random grain offset
/// @param useRandomGrainOffset Whether or not to set the grains to start at the initial position or a random position
- (void)setOptionalUseRandomGrainOffset:(BOOL)useRandomGrainOffset;


@end